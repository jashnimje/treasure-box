import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/data/app_database.dart';
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

  ItemDraft draft({
    String name = 'Iron Sword',
    ItemCategory category = ItemCategory.weapons,
    String iconKey = 'sword',
    int qty = 1,
    Rarity rarity = Rarity.common,
    String? notes,
    int? id,
  }) {
    return ItemDraft(
      id: id,
      name: name,
      category: category,
      iconKey: iconKey,
      qty: qty,
      rarity: rarity,
      notes: notes,
    );
  }

  test('currentBox seeds a default box', () async {
    final box = await repo.currentBox();
    expect(box.name, 'Treasure Box');
    expect(box.capacity, 27);
    expect(box.id, greaterThan(0));
  });

  test('insert then watch emits the new item', () async {
    final box = await repo.currentBox();
    final saved = await repo.upsertItem(box.id, draft());
    expect(saved.id, greaterThan(0));
    expect(saved.name, 'Iron Sword');

    final items = await repo.watchItems(box.id).first;
    expect(items, hasLength(1));
    expect(items.single.name, 'Iron Sword');
    expect(items.single.category, ItemCategory.weapons);
  });

  test('update changes fields and keeps createdAt', () async {
    final box = await repo.currentBox();
    final saved = await repo.upsertItem(box.id, draft());
    final originalCreated = saved.createdAt;

    final edited = await repo.upsertItem(
      box.id,
      draft(id: saved.id, name: 'Diamond Sword', rarity: Rarity.rare, qty: 3),
    );
    expect(edited.id, saved.id);
    expect(edited.name, 'Diamond Sword');
    expect(edited.rarity, Rarity.rare);
    expect(edited.qty, 3);
    expect(edited.createdAt, originalCreated);
  });

  test('delete removes the item', () async {
    final box = await repo.currentBox();
    final saved = await repo.upsertItem(box.id, draft());
    await repo.deleteItem(saved.id);
    final items = await repo.watchItems(box.id).first;
    expect(items, isEmpty);
  });

  test('slotCount counts stacks, not summed quantity', () async {
    final box = await repo.currentBox();
    await repo.upsertItem(box.id, draft(name: 'A', iconKey: 'gem', qty: 14));
    await repo.upsertItem(box.id, draft(name: 'B', iconKey: 'ingot', qty: 32));
    expect(await repo.slotCount(box.id), 2);
  });

  test('capacity: full chest blocks a new item but allows a qty edit',
      () async {
    final box = await repo.currentBox();
    await repo.setCapacity(box.id, 2);

    final a = await repo.upsertItem(box.id, draft(name: 'A', iconKey: 'gem'));
    await repo.upsertItem(box.id, draft(name: 'B', iconKey: 'ingot'));
    expect(await repo.slotCount(box.id), 2);

    // Caller enforces capacity on add; verify the signal it relies on.
    final full = await repo.slotCount(box.id) >= (await repo.currentBox()).capacity;
    expect(full, isTrue);

    // Editing an existing stack's qty must not add a slot.
    await repo.upsertItem(box.id, draft(id: a.id, name: 'A', iconKey: 'gem', qty: 99));
    expect(await repo.slotCount(box.id), 2);
  });

  test('setCapacity and renameBox persist', () async {
    final box = await repo.currentBox();
    await repo.renameBox(box.id, 'Loot Chest');
    await repo.setCapacity(box.id, 36);
    final updated = await repo.watchBox(box.id).first;
    expect(updated.name, 'Loot Chest');
    expect(updated.capacity, 36);
  });

  test('clearBox removes all items but keeps the box', () async {
    final box = await repo.currentBox();
    await repo.upsertItem(box.id, draft(name: 'A', iconKey: 'gem'));
    await repo.upsertItem(box.id, draft(name: 'B', iconKey: 'ingot'));
    await repo.clearBox(box.id);
    expect(await repo.watchItems(box.id).first, isEmpty);
    expect((await repo.currentBox()).id, box.id);
  });

  group('multi-box', () {
    test('createBox assigns sequential BOX-N codes', () async {
      final b1 = await repo.currentBox(); // default box = BOX-1
      final b2 = await repo.createBox(name: 'Garage');
      expect(b1.code, 'BOX-1');
      expect(b2.code, 'BOX-2');
      final boxes = await repo.watchBoxes().first;
      expect(boxes.length, 2);
    });

    test('deleted slots are reused so printed labels stay valid', () async {
      final b1 = await repo.currentBox(); // BOX-1
      final b2 = await repo.createBox(name: 'Garage'); // BOX-2
      final b3 = await repo.createBox(name: 'Attic'); // BOX-3
      expect([b1.code, b2.code, b3.code], ['BOX-1', 'BOX-2', 'BOX-3']);

      // Delete the middle box; the next box takes its slot.
      await repo.deleteBox(b2.id);
      final b4 = await repo.createBox(name: 'Basement');
      expect(b4.code, 'BOX-2');

      // Delete everything; new boxes start from BOX-1 again.
      await repo.deleteBox(b1.id);
      await repo.deleteBox(b3.id);
      await repo.deleteBox(b4.id);
      final fresh = await repo.createBox(name: 'New Life');
      expect(fresh.code, 'BOX-1');
    });

    test('boxByToken resolves the right box', () async {
      final b1 = await repo.currentBox();
      final b2 = await repo.createBox(name: 'Garage');
      expect((await repo.boxByToken(b2.qrToken!))!.id, b2.id);
      expect((await repo.boxByToken(b1.qrToken!))!.id, b1.id);
      expect(await repo.boxByToken('nope'), isNull);
    });

    test('boxByAnyCode resolves BOX-N, slot number, name, and deep link',
        () async {
      final b1 = await repo.currentBox(); // BOX-1
      final b2 = await repo.createBox(name: 'Garage'); // BOX-2

      // The canonical code, any casing.
      expect((await repo.boxByAnyCode('BOX-2'))!.id, b2.id);
      expect((await repo.boxByAnyCode('box-2'))!.id, b2.id);
      // A bare slot number (marker label says "1").
      expect((await repo.boxByAnyCode('1'))!.id, b1.id);
      // Exact name, case-insensitive.
      expect((await repo.boxByAnyCode('garage'))!.id, b2.id);
      // A full pasted deep link resolves via its last segment.
      expect((await repo.boxByAnyCode('/box/BOX-2'))!.id, b2.id);
      // Whitespace is tolerated; unknown codes are null.
      expect((await repo.boxByAnyCode('  BOX-1  '))!.id, b1.id);
      expect(await repo.boxByAnyCode('unknown-code'), isNull);
      expect(await repo.boxByAnyCode('   '), isNull);
    });

    test('deleteBox removes the box and cascades its items', () async {
      final b1 = await repo.currentBox();
      final b2 = await repo.createBox(name: 'Garage');
      await repo.upsertItem(b2.id, draft(name: 'Drill', iconKey: 'pickaxe'));
      await repo.deleteBox(b2.id);
      final boxes = await repo.watchBoxes().first;
      expect(boxes.map((b) => b.id), [b1.id]);
      expect(await repo.watchItems(b2.id).first, isEmpty);
    });

    test('findItems matches spot and notes, empty query returns nothing',
        () async {
      final b = await repo.currentBox();
      await repo.upsertItem(
        b.id,
        ItemDraft(
          name: 'Screws',
          category: ItemCategory.materials,
          iconKey: 'ingot',
          qty: 1,
          rarity: Rarity.common,
          spot: 'left drawer',
        ),
      );
      expect((await repo.findItems('drawer')).single.item.name, 'Screws');
      expect(await repo.findItems('   '), isEmpty);
    });
  });

}
