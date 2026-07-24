import 'item_category.dart';
import 'rarity.dart';

/// A single item stored in a treasure box. This is the domain model the UI and
/// state layer work with; it deliberately holds no Drift types so features
/// never depend on generated database code.
class Item {
  const Item({
    required this.id,
    required this.boxId,
    required this.name,
    required this.category,
    required this.iconKey,
    required this.qty,
    required this.rarity,
    required this.createdAt,
    required this.updatedAt,
    this.photoPath,
    this.notes,
    this.spot,
  });

  final int id;
  final int boxId;
  final String name;
  final ItemCategory category;
  final String iconKey;
  final String? photoPath;
  final int qty;
  final Rarity rarity;
  final String? notes;

  /// Optional finer location within the box (e.g. "2nd drawer").
  final String? spot;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// True when a real photo is attached and should take precedence over the
  /// pixel icon.
  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;
}

/// A pending create/update coming from the add/edit form. `id == null` means a
/// new item (insert); otherwise it updates the existing row.
class ItemDraft {
  const ItemDraft({
    required this.name,
    required this.category,
    required this.iconKey,
    required this.qty,
    required this.rarity,
    this.id,
    this.photoPath,
    this.notes,
    this.spot,
  });

  final int? id;
  final String name;
  final ItemCategory category;
  final String iconKey;
  final String? photoPath;
  final int qty;
  final Rarity rarity;
  final String? notes;
  final String? spot;

  bool get isNew => id == null;
}
