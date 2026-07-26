import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/data/app_database.dart';
import 'package:treasure_box/core/data/models/box_code.dart';
import 'package:treasure_box/core/data/models/item.dart';
import 'package:treasure_box/core/data/models/item_category.dart';
import 'package:treasure_box/core/data/models/rarity.dart';
import 'package:treasure_box/core/data/repositories/drift_inventory_repository.dart';
import 'package:treasure_box/core/data/repositories/inventory_repository.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late InventoryRepository repo;

  setUp(() {
    db = makeTestDatabase();
    repo = DriftInventoryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  ItemDraft draft(String name) => ItemDraft(
        name: name,
        category: ItemCategory.misc,
        iconKey: 'book',
        qty: 1,
        rarity: Rarity.common,
      );

  group('markOpenedVia', () {
    test('QR open stamps qrUsedAt only', () async {
      final box = await repo.currentBox();
      expect(box.hasQrRail, isFalse);

      await repo.markOpenedVia(box.id, BoxCodeSource.qr);
      final after = await repo.watchBox(box.id).first;
      expect(after.hasQrRail, isTrue);
      expect(after.nfcUsedAt, isNull);
    });

    test('NFC open stamps nfcUsedAt and earns the NFC rail', () async {
      final box = await repo.currentBox();
      expect(box.hasNfcRail, isFalse);

      await repo.markOpenedVia(box.id, BoxCodeSource.nfc);
      final after = await repo.watchBox(box.id).first;
      expect(after.hasNfcRail, isTrue);
      expect(after.qrUsedAt, isNull);
    });

    test('ID open stamps nothing', () async {
      final box = await repo.currentBox();
      await repo.markOpenedVia(box.id, BoxCodeSource.id);
      final after = await repo.watchBox(box.id).first;
      expect(after.qrUsedAt, isNull);
      expect(after.nfcUsedAt, isNull);
    });

    test('a linked tag also earns the NFC rail without a tap', () async {
      final box = await repo.currentBox();
      await repo.setNfcTag(box.id, 'ABCD1234');
      final after = await repo.watchBox(box.id).first;
      expect(after.hasNfcRail, isTrue);
      expect(after.nfcUsedAt, isNull);
    });
  });

  group('boxByAnyCode with envelope', () {
    test('resolves the enveloped QR string to the box', () async {
      final box = await repo.currentBox();
      final found = await repo.boxByAnyCode('TB:${box.code}:QR');
      expect(found?.id, box.id);
    });

    test('still resolves plain codes, ids and names', () async {
      final box = await repo.currentBox();
      expect((await repo.boxByAnyCode(box.code))?.id, box.id);
      expect((await repo.boxByAnyCode('${box.slot}'))?.id, box.id);
      expect((await repo.boxByAnyCode(box.name))?.id, box.id);
    });
  });

  group('watchRecentItems', () {
    test('orders newest first across boxes and respects the limit', () async {
      final box1 = await repo.currentBox();
      final box2 = await repo.createBox(name: 'Second');

      // Insert in a known order; same-timestamp rows fall back to id desc,
      // so the last insert always sorts first.
      await repo.upsertItem(box1.id, draft('First'));
      await repo.upsertItem(box2.id, draft('Second'));
      await repo.upsertItem(box1.id, draft('Third'));

      final recent = await repo.watchRecentItems(2).first;
      expect(recent, hasLength(2));
      expect(recent[0].item.name, 'Third');
      expect(recent[0].box.id, box1.id);
      expect(recent[1].item.name, 'Second');
      expect(recent[1].box.name, 'Second');
    });

    test('emits an empty list when there are no items', () async {
      await repo.currentBox();
      final recent = await repo.watchRecentItems(5).first;
      expect(recent, isEmpty);
    });
  });
}
