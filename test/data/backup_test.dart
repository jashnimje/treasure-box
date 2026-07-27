import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/data/app_database.dart';
import 'package:treasure_box/core/data/backup/backup_codec.dart';
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

  ItemDraft draft(String name, {String? spot, String? notes}) => ItemDraft(
        name: name,
        category: ItemCategory.misc,
        iconKey: 'book',
        qty: 2,
        rarity: Rarity.rare,
        spot: spot,
        notes: notes,
      );

  test('JSON export/import round-trips boxes and items', () async {
    final box = await repo.currentBox();
    await repo.upsertItem(box.id, draft('Passport', spot: 'side pocket'));
    await repo.upsertItem(box.id, draft('Old Coins', notes: 'silver ones'));

    final json = encodeBackupJson(await repo.exportBackup());

    // Restore into a FRESH database.
    final db2 = makeTestDatabase();
    addTearDown(db2.close);
    final repo2 = DriftInventoryRepository(db2);
    // Consume the default box so slots collide realistically.
    await repo2.currentBox();

    final written = await repo2.importBackup(decodeBackupJson(json));
    expect(written, 2);

    final restored = await repo2.findItems('passport');
    expect(restored.single.item.spot, 'side pocket');
    expect(restored.single.item.qty, 2);
    expect(restored.single.item.rarity, Rarity.rare);
    expect(restored.single.box.code, box.code);
  });

  test('re-importing the same backup adds nothing', () async {
    final box = await repo.currentBox();
    await repo.upsertItem(box.id, draft('Charging Cables'));
    final json = encodeBackupJson(await repo.exportBackup());

    expect(await repo.importBackup(decodeBackupJson(json)), 0);
    expect(await repo.slotCount(box.id), 1);
  });

  test('import creates missing boxes with their type and capacity',
      () async {
    await repo.currentBox(); // BOX-1 exists
    const source = '''
{"app":"treasure_box","format":1,"boxes":[
  {"name":"Garage Bin","code":"BOX-7","slot":7,"capacity":54,
   "skinKey":"trapped-large",
   "items":[{"name":"Drill","category":"tools","iconKey":"pickaxe",
             "qty":1,"rarity":"uncommon"}]}
]}''';
    final written = await repo.importBackup(decodeBackupJson(source));
    expect(written, 1);

    final found = await repo.findItems('drill');
    expect(found.single.box.name, 'Garage Bin');
    expect(found.single.box.code, 'BOX-7');
    expect(found.single.box.skinKey, 'trapped-large');
    expect(found.single.box.capacity, 54);
  });

  test('rejects files that are not backups', () {
    expect(() => decodeBackupJson('not json'),
        throwsA(isA<BackupFormatException>()));
    expect(() => decodeBackupJson('{"app":"other"}'),
        throwsA(isA<BackupFormatException>()));
    expect(() => decodeBackupJson('{"app":"treasure_box","boxes":[]}'),
        throwsA(isA<BackupFormatException>()));
  });

  test('photo refs survive the JSON round-trip as archive paths', () async {
    final box = await repo.currentBox();
    await repo.upsertItem(
        box.id,
        ItemDraft(
          name: 'Polaroids',
          category: ItemCategory.misc,
          iconKey: 'book',
          qty: 1,
          rarity: Rarity.rare,
          photoPath: '/data/user/0/app/cache/pic_1.jpg',
        ));

    final json = encodeBackupJson(await repo.exportBackup());
    expect(json, contains('"photo": "photos/box1-item'));

    final decoded = decodeBackupJson(json);
    final item = decoded.single.items.single;
    expect(item.photoPath, startsWith('photos/box1-item'));
    expect(item.photoPath, endsWith('.jpg'));
  });
}
