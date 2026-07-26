import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/data/models/inventory_query.dart';
import 'package:treasure_box/core/data/models/item.dart';
import 'package:treasure_box/core/data/models/item_category.dart';
import 'package:treasure_box/core/data/models/rarity.dart';

Item makeItem({
  required int id,
  required String name,
  ItemCategory category = ItemCategory.misc,
  int qty = 1,
  Rarity rarity = Rarity.common,
  String? notes,
  DateTime? createdAt,
}) {
  final now = createdAt ?? DateTime(2025, 1, 1);
  return Item(
    id: id,
    boxId: 1,
    name: name,
    category: category,
    iconKey: category.defaultIconKey,
    qty: qty,
    rarity: rarity,
    notes: notes,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final items = [
    makeItem(
      id: 1,
      name: 'Iron Sword',
      category: ItemCategory.weapons,
      qty: 2,
      rarity: Rarity.uncommon,
      createdAt: DateTime(2025, 1, 3),
    ),
    makeItem(
      id: 2,
      name: 'Diamond',
      category: ItemCategory.gems,
      qty: 14,
      rarity: Rarity.rare,
      notes: 'from a deep cave',
      createdAt: DateTime(2025, 1, 5),
    ),
    makeItem(
      id: 3,
      name: 'Gold Ingot',
      category: ItemCategory.materials,
      qty: 32,
      rarity: Rarity.common,
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  test('empty query returns all, sorted by name ascending', () {
    final result = applyInventoryQuery(items, const InventoryQuery());
    expect(result.map((i) => i.name), ['Diamond', 'Gold Ingot', 'Iron Sword']);
  });

  test('search matches name, category, or notes (case-insensitive)', () {
    expect(
      applyInventoryQuery(items, const InventoryQuery(searchText: 'iron'))
          .map((i) => i.name),
      ['Iron Sword'],
    );
    // Matches the note text on Diamond.
    expect(
      applyInventoryQuery(items, const InventoryQuery(searchText: 'CAVE'))
          .map((i) => i.name),
      ['Diamond'],
    );
    // Matches a category label.
    expect(
      applyInventoryQuery(items, const InventoryQuery(searchText: 'gems'))
          .map((i) => i.name),
      ['Diamond'],
    );
  });

  test('category filter narrows the list', () {
    final result = applyInventoryQuery(
      items,
      const InventoryQuery(category: ItemCategory.materials),
    );
    expect(result.map((i) => i.name), ['Gold Ingot']);
  });

  test('sort by quantity descending', () {
    final result =
        applyInventoryQuery(items, const InventoryQuery(sort: SortKey.qtyDesc));
    expect(result.map((i) => i.qty), [32, 14, 2]);
  });

  test('sort by recently added descending', () {
    final result = applyInventoryQuery(
      items,
      const InventoryQuery(sort: SortKey.recentlyAdded),
    );
    expect(result.map((i) => i.name), ['Diamond', 'Iron Sword', 'Gold Ingot']);
  });

  test('sort by rarity descending puts rarest first', () {
    final result = applyInventoryQuery(
      items,
      const InventoryQuery(sort: SortKey.rarityDesc),
    );
    expect(result.first.name, 'Diamond'); // rare
    expect(result.last.name, 'Gold Ingot'); // common
  });
}
