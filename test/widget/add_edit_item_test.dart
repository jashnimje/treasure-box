import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_box/core/data/app_database.dart';
import 'package:treasure_box/core/data/models/item.dart';
import 'package:treasure_box/core/data/models/item_category.dart';
import 'package:treasure_box/core/data/models/rarity.dart';
import 'package:treasure_box/core/data/repositories/drift_inventory_repository.dart';
import 'package:treasure_box/features/add_item/add_edit_item_screen.dart';

import '../support/test_database.dart';
import '../support/widget_harness.dart';

void main() {
  late AppDatabase db;
  late DriftInventoryRepository repo;
  setUp(() {
    db = makeTestDatabase();
    repo = DriftInventoryRepository(db);
  });
  tearDown(() => db.close());

  // Real Drift I/O needs the real event loop, so DB reads run inside runAsync.

  testWidgets('saving a named item writes it to the chest', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(
      wrapForTest(db: db, child: const AddEditItemScreen()),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'Golden Apple');
    await tester.tap(find.text('Save to chest'));
    await tester.pump();

    final items = await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final box = await repo.currentBox();
      return repo.watchItems(box.id).first;
    });
    expect(items, hasLength(1));
    expect(items!.single.name, 'Golden Apple');
    await disposeApp(tester);
  });

  testWidgets('empty name is rejected with a message', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(
      wrapForTest(db: db, child: const AddEditItemScreen()),
    );
    await tester.pump();

    await tester.tap(find.text('Save to chest'));
    await tester.pump();

    expect(find.text('Give the item a name'), findsOneWidget);
    final items = await tester.runAsync(() async {
      final box = await repo.currentBox();
      return repo.watchItems(box.id).first;
    });
    expect(items, isEmpty);
    await disposeApp(tester);
  });

  testWidgets('full chest blocks a new item', (tester) async {
    await tester.runAsync(() async {
      final box = await repo.currentBox();
      await repo.setCapacity(box.id, 1);
      await repo.upsertItem(
        box.id,
        const ItemDraft(
          name: 'Sword',
          category: ItemCategory.weapons,
          iconKey: 'sword',
          qty: 1,
          rarity: Rarity.common,
        ),
      );
    });

    useTallSurface(tester);
    await tester.pumpWidget(
      wrapForTest(db: db, child: const AddEditItemScreen()),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'Overflow Item');
    await tester.tap(find.text('Save to chest'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();

    expect(find.textContaining('Chest is full'), findsOneWidget);
    final items = await tester.runAsync(() async {
      final box = await repo.currentBox();
      return repo.watchItems(box.id).first;
    });
    expect(items, hasLength(1));
    await disposeApp(tester);
  });
}
