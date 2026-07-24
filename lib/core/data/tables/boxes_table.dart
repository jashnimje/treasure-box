import 'package:drift/drift.dart';

/// A treasure box. Multiple boxes are supported; each is placed in the room and
/// can be opened by tapping it, or (later) by scanning its NFC tag / QR token.
@DataClassName('BoxRow')
class Boxes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withDefault(const Constant('Treasure Box'))();

  /// Maximum number of item stacks/slots (not summed quantity).
  IntColumn get capacity => integer().withDefault(const Constant(27))();

  /// The linked NFC tag id, if any.
  TextColumn get nfcTagId => text().nullable()();

  /// The box's human code, e.g. `BOX-1` - the single identity every rail
  /// (QR, NFC payload, typed id) carries. Derived from [slot].
  TextColumn get qrToken => text().nullable()();

  /// Identity slot number. Assigned as the LOWEST free positive integer at
  /// creation, so deleting all boxes and creating new ones reuses BOX-1
  /// first - printed QR labels and written NFC tags stay valid.
  IntColumn get slot => integer().withDefault(const Constant(0))();

  /// Chest skin cosmetic key (e.g. oak/trapped/ender). Defaults to oak.
  TextColumn get skinKey => text().withDefault(const Constant('oak'))();

  /// Display order in lists.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// When this box was last opened via a scanned QR envelope. Null until the
  /// QR rail is actually used - badges are earned, not declared.
  DateTimeColumn get qrUsedAt => dateTime().nullable()();

  /// When this box was last opened via an NFC tap (payload or linked tag id).
  /// Independent of [nfcTagId], which only means a tag was written/linked.
  DateTimeColumn get nfcUsedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
