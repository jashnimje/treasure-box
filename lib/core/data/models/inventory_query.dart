import 'item.dart';
import 'item_category.dart';

/// How the inventory list is ordered.
enum SortKey {
  nameAsc('Name A-Z'),
  qtyDesc('Quantity'),
  recentlyAdded('Recently added'),
  rarityDesc('Rarity');

  const SortKey(this.label);

  final String label;
}

/// The current search / filter / sort state for the inventory list. Immutable;
/// [copyWith] produces a new instance for the Riverpod notifier.
class InventoryQuery {
  const InventoryQuery({
    this.searchText = '',
    this.category,
    this.sort = SortKey.nameAsc,
  });

  final String searchText;

  /// Null means "all categories".
  final ItemCategory? category;
  final SortKey sort;

  bool get isFiltering => searchText.trim().isNotEmpty || category != null;

  InventoryQuery copyWith({
    String? searchText,
    ItemCategory? category,
    bool clearCategory = false,
    SortKey? sort,
  }) {
    return InventoryQuery(
      searchText: searchText ?? this.searchText,
      category: clearCategory ? null : (category ?? this.category),
      sort: sort ?? this.sort,
    );
  }
}

/// Applies a query to a list of items. Pure and side-effect free so it can be
/// unit-tested directly without a database or widget tree.
List<Item> applyInventoryQuery(List<Item> items, InventoryQuery query) {
  final search = query.searchText.trim().toLowerCase();

  final filtered = items.where((item) {
    if (query.category != null && item.category != query.category) {
      return false;
    }
    if (search.isEmpty) return true;
    return item.name.toLowerCase().contains(search) ||
        item.category.label.toLowerCase().contains(search) ||
        (item.notes?.toLowerCase().contains(search) ?? false);
  }).toList();

  filtered.sort((a, b) {
    switch (query.sort) {
      case SortKey.nameAsc:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case SortKey.qtyDesc:
        return b.qty.compareTo(a.qty);
      case SortKey.recentlyAdded:
        return b.createdAt.compareTo(a.createdAt);
      case SortKey.rarityDesc:
        // Higher rarity first; break ties by name for a stable order.
        final byRarity = b.rarity.index.compareTo(a.rarity.index);
        return byRarity != 0
            ? byRarity
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }
  });

  return filtered;
}
