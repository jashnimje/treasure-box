import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/items_table.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(super.db);

  /// Reactive stream of every item in a box. Filtering/sorting is applied in
  /// Dart on top of this (datasets are small), keeping this the single source.
  Stream<List<ItemRow>> watchItemsForBox(int boxId) {
    return (select(items)..where((i) => i.boxId.equals(boxId))).watch();
  }

  Future<ItemRow?> getItem(int id) {
    return (select(items)..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  /// All items across every box (for global search snapshots).
  Future<List<ItemRow>> allItems() => select(items).get();

  /// The most recently added items across all boxes (Activity tab).
  Stream<List<ItemRow>> watchRecentItems(int limit) {
    return (select(items)
          ..orderBy([
            (i) => OrderingTerm(
                expression: i.createdAt, mode: OrderingMode.desc),
            (i) => OrderingTerm(expression: i.id, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  Future<int> insertItem(ItemsCompanion item) => into(items).insert(item);

  Future<bool> updateItem(ItemsCompanion item) => update(items).replace(item);

  Future<void> deleteItem(int id) {
    return (delete(items)..where((i) => i.id.equals(id))).go();
  }

  /// Number of item stacks/slots in a box (the capacity unit).
  Future<int> countForBox(int boxId) async {
    final countExp = items.id.count();
    final query = selectOnly(items)
      ..addColumns([countExp])
      ..where(items.boxId.equals(boxId));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

}
