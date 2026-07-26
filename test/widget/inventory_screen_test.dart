import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/data/app_database.dart';
import 'package:treasure_box/core/data/models/item.dart';
import 'package:treasure_box/core/data/models/item_category.dart';
import 'package:treasure_box/core/data/models/rarity.dart';
import 'package:treasure_box/core/data/repositories/drift_inventory_repository.dart';
import 'package:treasure_box/features/inventory/inventory_screen.dart';
import 'package:treasure_box/features/inventory/widgets/inventory_item_tile.dart';

import '../support/test_database.dart';
import '../support/widget_harness.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = makeTestDatabase());
  tearDown(() => db.close());

  Future<void> seed() async {
    final repo = DriftInventoryRepository(db);
    final box = await repo.currentBox();
    await repo.upsertItem(
      box.id,
      const ItemDraft(
        name: 'Iron Sword',
        category: ItemCategory.weapons,
        iconKey: 'sword',
        qty: 2,
        rarity: Rarity.uncommon,
      ),
    );
    await repo.upsertItem(
      box.id,
      const ItemDraft(
        name: 'Diamond',
        category: ItemCategory.gems,
        iconKey: 'gem',
        qty: 14,
        rarity: Rarity.rare,
      ),
    );
  }

  testWidgets('renders seeded items and capacity text', (tester) async {
    await seed();
    useTallSurface(tester);
    await tester.pumpWidget(wrapForTest(db: db, child: const InventoryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Iron Sword'), findsOneWidget);
    expect(find.text('Diamond'), findsOneWidget);
    expect(find.byType(InventoryItemTile), findsNWidgets(2));
    // Capacity bar: 2 used of the seeded default 27.
    expect(find.text('2/27'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('search filters the list', (tester) async {
    await seed();
    useTallSurface(tester);
    await tester.pumpWidget(wrapForTest(db: db, child: const InventoryScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'diamond');
    await tester.pumpAndSettle();

    expect(find.text('Diamond'), findsOneWidget);
    expect(find.text('Iron Sword'), findsNothing);
    expect(find.byType(InventoryItemTile), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('empty chest shows the empty state', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(wrapForTest(db: db, child: const InventoryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('The chest is empty'), findsOneWidget);
    expect(find.byType(InventoryItemTile), findsNothing);
    await disposeApp(tester);
  });
}
