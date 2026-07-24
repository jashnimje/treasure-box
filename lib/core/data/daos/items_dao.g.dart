// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_dao.dart';

// ignore_for_file: type=lint
mixin _$ItemsDaoMixin on DatabaseAccessor<AppDatabase> {
  $BoxesTable get boxes => attachedDatabase.boxes;
  $ItemsTable get items => attachedDatabase.items;
  ItemsDaoManager get managers => ItemsDaoManager(this);
}

class ItemsDaoManager {
  final _$ItemsDaoMixin _db;
  ItemsDaoManager(this._db);
  $$BoxesTableTableManager get boxes =>
      $$BoxesTableTableManager(_db.attachedDatabase, _db.boxes);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
}
