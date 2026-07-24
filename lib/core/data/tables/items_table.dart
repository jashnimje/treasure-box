import 'package:drift/drift.dart';

import 'boxes_table.dart';

/// A single item stored in a box. Enums (`category`, `rarity`) are stored as
/// their string names so rows stay human-readable.
@DataClassName('ItemRow')
class Items extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Owning box. Deleting a box cascades to its items.
  IntColumn get boxId =>
      integer().references(Boxes, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text().withLength(min: 1, max: 80)();

  /// ItemCategory.name
  TextColumn get category => text()();

  /// Pixel sprite key (matches a key in `pixelSprites`).
  TextColumn get iconKey => text()();

  /// Local file path to an optional real photo.
  TextColumn get photoPath => text().nullable()();

  IntColumn get qty => integer().withDefault(const Constant(1))();

  /// Rarity.name
  TextColumn get rarity => text().withDefault(const Constant('common'))();

  TextColumn get notes => text().nullable()();

  /// Optional finer location within the box (e.g. "2nd drawer", "side pocket"),
  /// used by find-my-stuff.
  TextColumn get spot => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
