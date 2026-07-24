import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/inventory_query.dart';
import '../data/models/item.dart';
import '../data/models/item_category.dart';
import 'box_providers.dart';

/// Holds the current search / filter / sort state for the inventory list.
class InventoryQueryNotifier extends Notifier<InventoryQuery> {
  @override
  InventoryQuery build() => const InventoryQuery();

  void setSearch(String text) => state = state.copyWith(searchText: text);

  void setCategory(ItemCategory? category) {
    state = category == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(category: category);
  }

  void setSort(SortKey sort) => state = state.copyWith(sort: sort);

  void clear() => state = const InventoryQuery();
}

final inventoryQueryProvider =
    NotifierProvider<InventoryQueryNotifier, InventoryQuery>(
  InventoryQueryNotifier.new,
);

/// The inventory items after search/filter/sort are applied. Preserves the
/// async loading/error state of the underlying stream.
final filteredItemsProvider = Provider<AsyncValue<List<Item>>>((ref) {
  final itemsAsync = ref.watch(itemsProvider);
  final query = ref.watch(inventoryQueryProvider);
  return itemsAsync.whenData((items) => applyInventoryQuery(items, query));
});
