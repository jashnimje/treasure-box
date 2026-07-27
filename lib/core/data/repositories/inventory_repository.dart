import '../backup/backup_codec.dart';
import '../models/box.dart';
import '../models/box_code.dart';
import '../models/item.dart';

/// An item paired with the box it lives in - the result of a cross-box search
/// ("where is my X").
class FoundItem {
  const FoundItem({required this.item, required this.box});

  final Item item;
  final Box box;
}

/// The boundary between the UI/state layer and persistence. Features depend on
/// this interface and the lightweight domain models, never on Drift types.
abstract class InventoryRepository {
  /// Reactive list of items in a box; re-emits on every change.
  Stream<List<Item>> watchItems(int boxId);

  Future<Item?> getItem(int id);

  /// Insert (draft.isNew) or update an item. Returns the saved item.
  Future<Item> upsertItem(int boxId, ItemDraft draft);

  Future<void> deleteItem(int id);

  /// Number of stacks/slots used in a box (the capacity unit).
  Future<int> slotCount(int boxId);

  // ---- Boxes (multi-box) ----

  /// Reactive list of all boxes, ordered for display.
  Stream<List<Box>> watchBoxes();

  Stream<Box> watchBox(int id);

  /// The first box, created (with a token) if none exists. Used as a default.
  Future<Box> currentBox();

  /// Create a new box; returns it (with a fresh token).
  Future<Box> createBox({String name, String skinKey});

  Future<void> renameBox(int id, String name);

  Future<void> setCapacity(int id, int capacity);

  /// Change the chest's look (skin and single/large type key).
  Future<void> setSkin(int id, String skinKey);

  Future<void> setNfcTag(int id, String? tagId);

  /// Delete a box and its items.
  Future<void> deleteBox(int id);

  /// Resolve a box by its QR/NFC token (deep-link target). Null if unknown.
  Future<Box?> boxByToken(String token);

  /// Resolve a box by any identity a user can present: the QR/NFC token
  /// (with or without the `TB:...:QR` envelope), the plain numeric box id
  /// (printed on a label), or an exact name match. Null if nothing matches.
  Future<Box?> boxByAnyCode(String code);

  /// Record that a box was opened via [source] (auto-learned rail badges).
  /// The ID rail is not stored - the code always works.
  Future<void> markOpenedVia(int boxId, BoxCodeSource source);

  /// Reactive stream of the most recently added items across all boxes,
  /// each paired with its owning box (Activity tab).
  Stream<List<FoundItem>> watchRecentItems(int limit);

  /// Delete every item in the box.
  Future<void> clearBox(int id);

  // ---- Cross-box search (find-my-stuff) ----

  /// Find items across all boxes whose name/category/notes/spot match [query].
  /// Returns each match paired with its owning box.
  Future<List<FoundItem>> findItems(String query);

  // ---- Backup ----

  /// Snapshot of every box and item, for export.
  Future<Backup> exportBackup();

  /// Restore boxes from an import. Boxes are matched by slot code: a match
  /// merges items into the existing box (skipping exact-name duplicates);
  /// no match creates the box. Returns the number of items written.
  Future<int> importBackup(List<ImportedBox> boxes);
}
