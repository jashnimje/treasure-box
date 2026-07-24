/// Item categories, matching the wooden-sign dropdown in the mock.
///
/// Stored in the database as [ItemCategory.name] (a string). Each category has
/// a default pixel [iconKey] used when the user has not chosen one explicitly.
enum ItemCategory {
  weapons('Weapons', 'sword'),
  tools('Tools', 'pickaxe'),
  materials('Materials', 'ingot'),
  gems('Gems', 'gem'),
  consumables('Consumables', 'potion'),
  food('Food', 'apple'),
  misc('Misc', 'book');

  const ItemCategory(this.label, this.defaultIconKey);

  /// Human-facing label shown in the UI.
  final String label;

  /// Fallback pixel sprite key for items in this category.
  final String defaultIconKey;

  /// Parse a stored string back into a category, defaulting to [misc].
  static ItemCategory fromName(String? value) {
    return ItemCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ItemCategory.misc,
    );
  }
}
