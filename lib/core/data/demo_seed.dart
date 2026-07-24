import 'package:drift/drift.dart';

import 'app_database.dart';

/// Whether to seed sample items when the database is first created. Off by
/// default; enable with `flutter run --dart-define=DEMO=true` for demos and
/// screenshots only. Never affects normal builds.
const bool kDemoSeed = bool.fromEnvironment('DEMO');

/// Sample item rows inserted during `onCreate` when [kDemoSeed] is set.
List<ItemsCompanion> demoItemRows(int boxId, DateTime now) {
  ItemsCompanion row({
    required String name,
    required String category,
    required String iconKey,
    required int qty,
    required String rarity,
    String? notes,
  }) {
    return ItemsCompanion.insert(
      boxId: boxId,
      name: name,
      category: category,
      iconKey: iconKey,
      qty: Value(qty),
      rarity: Value(rarity),
      notes: Value(notes),
      createdAt: now,
      updatedAt: now,
    );
  }

  return [
    row(
      name: 'Swiss Army Knife',
      category: 'tools',
      iconKey: 'sword',
      qty: 1,
      rarity: 'rare',
      notes: 'The red one from the trek. Scissors are the good part.',
    ),
    row(
      name: 'Grandma\'s Ring',
      category: 'gems',
      iconKey: 'gem',
      qty: 1,
      rarity: 'legendary',
      notes: 'In the small velvet pouch. Handle with care.',
    ),
    row(
      name: 'Spare House Keys',
      category: 'misc',
      iconKey: 'ingot',
      qty: 2,
      rarity: 'common',
    ),
    row(
      name: 'Concert Tickets',
      category: 'misc',
      iconKey: 'book',
      qty: 2,
      rarity: 'epic',
      notes: 'Kept as souvenirs from the first show together.',
    ),
    row(
      name: 'Old Coins',
      category: 'materials',
      iconKey: 'ingot',
      qty: 23,
      rarity: 'uncommon',
    ),
    row(
      name: 'Polaroids',
      category: 'misc',
      iconKey: 'book',
      qty: 14,
      rarity: 'rare',
      notes: 'Summer trip photos, bound with the yellow rubber band.',
    ),
    row(
      name: 'Chocolate Stash',
      category: 'food',
      iconKey: 'apple',
      qty: 5,
      rarity: 'legendary',
    ),
  ];
}

/// A second sample box's items (demo only), with per-item spots to showcase
/// find-my-stuff across boxes.
List<ItemsCompanion> demoSecondBoxItemRows(int boxId, DateTime now) {
  ItemsCompanion row({
    required String name,
    required String category,
    required String iconKey,
    required int qty,
    required String rarity,
    String? spot,
  }) {
    return ItemsCompanion.insert(
      boxId: boxId,
      name: name,
      category: category,
      iconKey: iconKey,
      qty: Value(qty),
      rarity: Value(rarity),
      spot: Value(spot),
      createdAt: now,
      updatedAt: now,
    );
  }

  return [
    row(
      name: 'Winter Gloves',
      category: 'misc',
      iconKey: 'book',
      qty: 2,
      rarity: 'common',
      spot: 'top tray',
    ),
    row(
      name: 'Passport',
      category: 'misc',
      iconKey: 'book',
      qty: 1,
      rarity: 'epic',
      spot: 'side pocket',
    ),
    row(
      name: 'Charging Cables',
      category: 'tools',
      iconKey: 'pickaxe',
      qty: 4,
      rarity: 'common',
    ),
  ];
}
