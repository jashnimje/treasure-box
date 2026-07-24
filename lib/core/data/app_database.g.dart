// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BoxesTable extends Boxes with TableInfo<$BoxesTable, BoxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoxesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Treasure Box'),
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(27),
  );
  static const VerificationMeta _nfcTagIdMeta = const VerificationMeta(
    'nfcTagId',
  );
  @override
  late final GeneratedColumn<String> nfcTagId = GeneratedColumn<String>(
    'nfc_tag_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qrTokenMeta = const VerificationMeta(
    'qrToken',
  );
  @override
  late final GeneratedColumn<String> qrToken = GeneratedColumn<String>(
    'qr_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skinKeyMeta = const VerificationMeta(
    'skinKey',
  );
  @override
  late final GeneratedColumn<String> skinKey = GeneratedColumn<String>(
    'skin_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('oak'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _qrUsedAtMeta = const VerificationMeta(
    'qrUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> qrUsedAt = GeneratedColumn<DateTime>(
    'qr_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nfcUsedAtMeta = const VerificationMeta(
    'nfcUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> nfcUsedAt = GeneratedColumn<DateTime>(
    'nfc_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    capacity,
    nfcTagId,
    qrToken,
    slot,
    skinKey,
    sortOrder,
    qrUsedAt,
    nfcUsedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'boxes';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    }
    if (data.containsKey('nfc_tag_id')) {
      context.handle(
        _nfcTagIdMeta,
        nfcTagId.isAcceptableOrUnknown(data['nfc_tag_id']!, _nfcTagIdMeta),
      );
    }
    if (data.containsKey('qr_token')) {
      context.handle(
        _qrTokenMeta,
        qrToken.isAcceptableOrUnknown(data['qr_token']!, _qrTokenMeta),
      );
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
    if (data.containsKey('skin_key')) {
      context.handle(
        _skinKeyMeta,
        skinKey.isAcceptableOrUnknown(data['skin_key']!, _skinKeyMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('qr_used_at')) {
      context.handle(
        _qrUsedAtMeta,
        qrUsedAt.isAcceptableOrUnknown(data['qr_used_at']!, _qrUsedAtMeta),
      );
    }
    if (data.containsKey('nfc_used_at')) {
      context.handle(
        _nfcUsedAtMeta,
        nfcUsedAt.isAcceptableOrUnknown(data['nfc_used_at']!, _nfcUsedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BoxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoxRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      )!,
      nfcTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nfc_tag_id'],
      ),
      qrToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qr_token'],
      ),
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      skinKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skin_key'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      qrUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}qr_used_at'],
      ),
      nfcUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}nfc_used_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BoxesTable createAlias(String alias) {
    return $BoxesTable(attachedDatabase, alias);
  }
}

class BoxRow extends DataClass implements Insertable<BoxRow> {
  final int id;
  final String name;

  /// Maximum number of item stacks/slots (not summed quantity).
  final int capacity;

  /// The linked NFC tag id, if any.
  final String? nfcTagId;

  /// The box's human code, e.g. `BOX-1` - the single identity every rail
  /// (QR, NFC payload, typed id) carries. Derived from [slot].
  final String? qrToken;

  /// Identity slot number. Assigned as the LOWEST free positive integer at
  /// creation, so deleting all boxes and creating new ones reuses BOX-1
  /// first - printed QR labels and written NFC tags stay valid.
  final int slot;

  /// Chest skin cosmetic key (e.g. oak/spruce/ender). Defaults to oak.
  final String skinKey;

  /// Display order in lists.
  final int sortOrder;

  /// When this box was last opened via a scanned QR envelope. Null until the
  /// QR rail is actually used - badges are earned, not declared.
  final DateTime? qrUsedAt;

  /// When this box was last opened via an NFC tap (payload or linked tag id).
  /// Independent of [nfcTagId], which only means a tag was written/linked.
  final DateTime? nfcUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BoxRow({
    required this.id,
    required this.name,
    required this.capacity,
    this.nfcTagId,
    this.qrToken,
    required this.slot,
    required this.skinKey,
    required this.sortOrder,
    this.qrUsedAt,
    this.nfcUsedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['capacity'] = Variable<int>(capacity);
    if (!nullToAbsent || nfcTagId != null) {
      map['nfc_tag_id'] = Variable<String>(nfcTagId);
    }
    if (!nullToAbsent || qrToken != null) {
      map['qr_token'] = Variable<String>(qrToken);
    }
    map['slot'] = Variable<int>(slot);
    map['skin_key'] = Variable<String>(skinKey);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || qrUsedAt != null) {
      map['qr_used_at'] = Variable<DateTime>(qrUsedAt);
    }
    if (!nullToAbsent || nfcUsedAt != null) {
      map['nfc_used_at'] = Variable<DateTime>(nfcUsedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BoxesCompanion toCompanion(bool nullToAbsent) {
    return BoxesCompanion(
      id: Value(id),
      name: Value(name),
      capacity: Value(capacity),
      nfcTagId: nfcTagId == null && nullToAbsent
          ? const Value.absent()
          : Value(nfcTagId),
      qrToken: qrToken == null && nullToAbsent
          ? const Value.absent()
          : Value(qrToken),
      slot: Value(slot),
      skinKey: Value(skinKey),
      sortOrder: Value(sortOrder),
      qrUsedAt: qrUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(qrUsedAt),
      nfcUsedAt: nfcUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nfcUsedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BoxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoxRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      capacity: serializer.fromJson<int>(json['capacity']),
      nfcTagId: serializer.fromJson<String?>(json['nfcTagId']),
      qrToken: serializer.fromJson<String?>(json['qrToken']),
      slot: serializer.fromJson<int>(json['slot']),
      skinKey: serializer.fromJson<String>(json['skinKey']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      qrUsedAt: serializer.fromJson<DateTime?>(json['qrUsedAt']),
      nfcUsedAt: serializer.fromJson<DateTime?>(json['nfcUsedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'capacity': serializer.toJson<int>(capacity),
      'nfcTagId': serializer.toJson<String?>(nfcTagId),
      'qrToken': serializer.toJson<String?>(qrToken),
      'slot': serializer.toJson<int>(slot),
      'skinKey': serializer.toJson<String>(skinKey),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'qrUsedAt': serializer.toJson<DateTime?>(qrUsedAt),
      'nfcUsedAt': serializer.toJson<DateTime?>(nfcUsedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BoxRow copyWith({
    int? id,
    String? name,
    int? capacity,
    Value<String?> nfcTagId = const Value.absent(),
    Value<String?> qrToken = const Value.absent(),
    int? slot,
    String? skinKey,
    int? sortOrder,
    Value<DateTime?> qrUsedAt = const Value.absent(),
    Value<DateTime?> nfcUsedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BoxRow(
    id: id ?? this.id,
    name: name ?? this.name,
    capacity: capacity ?? this.capacity,
    nfcTagId: nfcTagId.present ? nfcTagId.value : this.nfcTagId,
    qrToken: qrToken.present ? qrToken.value : this.qrToken,
    slot: slot ?? this.slot,
    skinKey: skinKey ?? this.skinKey,
    sortOrder: sortOrder ?? this.sortOrder,
    qrUsedAt: qrUsedAt.present ? qrUsedAt.value : this.qrUsedAt,
    nfcUsedAt: nfcUsedAt.present ? nfcUsedAt.value : this.nfcUsedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BoxRow copyWithCompanion(BoxesCompanion data) {
    return BoxRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      nfcTagId: data.nfcTagId.present ? data.nfcTagId.value : this.nfcTagId,
      qrToken: data.qrToken.present ? data.qrToken.value : this.qrToken,
      slot: data.slot.present ? data.slot.value : this.slot,
      skinKey: data.skinKey.present ? data.skinKey.value : this.skinKey,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      qrUsedAt: data.qrUsedAt.present ? data.qrUsedAt.value : this.qrUsedAt,
      nfcUsedAt: data.nfcUsedAt.present ? data.nfcUsedAt.value : this.nfcUsedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoxRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('nfcTagId: $nfcTagId, ')
          ..write('qrToken: $qrToken, ')
          ..write('slot: $slot, ')
          ..write('skinKey: $skinKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('qrUsedAt: $qrUsedAt, ')
          ..write('nfcUsedAt: $nfcUsedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    capacity,
    nfcTagId,
    qrToken,
    slot,
    skinKey,
    sortOrder,
    qrUsedAt,
    nfcUsedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoxRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.capacity == this.capacity &&
          other.nfcTagId == this.nfcTagId &&
          other.qrToken == this.qrToken &&
          other.slot == this.slot &&
          other.skinKey == this.skinKey &&
          other.sortOrder == this.sortOrder &&
          other.qrUsedAt == this.qrUsedAt &&
          other.nfcUsedAt == this.nfcUsedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BoxesCompanion extends UpdateCompanion<BoxRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> capacity;
  final Value<String?> nfcTagId;
  final Value<String?> qrToken;
  final Value<int> slot;
  final Value<String> skinKey;
  final Value<int> sortOrder;
  final Value<DateTime?> qrUsedAt;
  final Value<DateTime?> nfcUsedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BoxesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.capacity = const Value.absent(),
    this.nfcTagId = const Value.absent(),
    this.qrToken = const Value.absent(),
    this.slot = const Value.absent(),
    this.skinKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.qrUsedAt = const Value.absent(),
    this.nfcUsedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BoxesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.capacity = const Value.absent(),
    this.nfcTagId = const Value.absent(),
    this.qrToken = const Value.absent(),
    this.slot = const Value.absent(),
    this.skinKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.qrUsedAt = const Value.absent(),
    this.nfcUsedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BoxRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? capacity,
    Expression<String>? nfcTagId,
    Expression<String>? qrToken,
    Expression<int>? slot,
    Expression<String>? skinKey,
    Expression<int>? sortOrder,
    Expression<DateTime>? qrUsedAt,
    Expression<DateTime>? nfcUsedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (capacity != null) 'capacity': capacity,
      if (nfcTagId != null) 'nfc_tag_id': nfcTagId,
      if (qrToken != null) 'qr_token': qrToken,
      if (slot != null) 'slot': slot,
      if (skinKey != null) 'skin_key': skinKey,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (qrUsedAt != null) 'qr_used_at': qrUsedAt,
      if (nfcUsedAt != null) 'nfc_used_at': nfcUsedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BoxesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? capacity,
    Value<String?>? nfcTagId,
    Value<String?>? qrToken,
    Value<int>? slot,
    Value<String>? skinKey,
    Value<int>? sortOrder,
    Value<DateTime?>? qrUsedAt,
    Value<DateTime?>? nfcUsedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BoxesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      nfcTagId: nfcTagId ?? this.nfcTagId,
      qrToken: qrToken ?? this.qrToken,
      slot: slot ?? this.slot,
      skinKey: skinKey ?? this.skinKey,
      sortOrder: sortOrder ?? this.sortOrder,
      qrUsedAt: qrUsedAt ?? this.qrUsedAt,
      nfcUsedAt: nfcUsedAt ?? this.nfcUsedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (nfcTagId.present) {
      map['nfc_tag_id'] = Variable<String>(nfcTagId.value);
    }
    if (qrToken.present) {
      map['qr_token'] = Variable<String>(qrToken.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (skinKey.present) {
      map['skin_key'] = Variable<String>(skinKey.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (qrUsedAt.present) {
      map['qr_used_at'] = Variable<DateTime>(qrUsedAt.value);
    }
    if (nfcUsedAt.present) {
      map['nfc_used_at'] = Variable<DateTime>(nfcUsedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoxesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('nfcTagId: $nfcTagId, ')
          ..write('qrToken: $qrToken, ')
          ..write('slot: $slot, ')
          ..write('skinKey: $skinKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('qrUsedAt: $qrUsedAt, ')
          ..write('nfcUsedAt: $nfcUsedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _boxIdMeta = const VerificationMeta('boxId');
  @override
  late final GeneratedColumn<int> boxId = GeneratedColumn<int>(
    'box_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES boxes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('common'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spotMeta = const VerificationMeta('spot');
  @override
  late final GeneratedColumn<String> spot = GeneratedColumn<String>(
    'spot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    boxId,
    name,
    category,
    iconKey,
    photoPath,
    qty,
    rarity,
    notes,
    spot,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('box_id')) {
      context.handle(
        _boxIdMeta,
        boxId.isAcceptableOrUnknown(data['box_id']!, _boxIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boxIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('spot')) {
      context.handle(
        _spotMeta,
        spot.isAcceptableOrUnknown(data['spot']!, _spotMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      boxId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rarity'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      spot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spot'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final int id;

  /// Owning box. Deleting a box cascades to its items.
  final int boxId;
  final String name;

  /// ItemCategory.name
  final String category;

  /// Pixel sprite key (matches a key in `pixelSprites`).
  final String iconKey;

  /// Local file path to an optional real photo.
  final String? photoPath;
  final int qty;

  /// Rarity.name
  final String rarity;
  final String? notes;

  /// Optional finer location within the box (e.g. "2nd drawer", "side pocket"),
  /// used by find-my-stuff.
  final String? spot;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ItemRow({
    required this.id,
    required this.boxId,
    required this.name,
    required this.category,
    required this.iconKey,
    this.photoPath,
    required this.qty,
    required this.rarity,
    this.notes,
    this.spot,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['box_id'] = Variable<int>(boxId);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['icon_key'] = Variable<String>(iconKey);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['qty'] = Variable<int>(qty);
    map['rarity'] = Variable<String>(rarity);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || spot != null) {
      map['spot'] = Variable<String>(spot);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      boxId: Value(boxId),
      name: Value(name),
      category: Value(category),
      iconKey: Value(iconKey),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      qty: Value(qty),
      rarity: Value(rarity),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      spot: spot == null && nullToAbsent ? const Value.absent() : Value(spot),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      id: serializer.fromJson<int>(json['id']),
      boxId: serializer.fromJson<int>(json['boxId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      qty: serializer.fromJson<int>(json['qty']),
      rarity: serializer.fromJson<String>(json['rarity']),
      notes: serializer.fromJson<String?>(json['notes']),
      spot: serializer.fromJson<String?>(json['spot']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'boxId': serializer.toJson<int>(boxId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'iconKey': serializer.toJson<String>(iconKey),
      'photoPath': serializer.toJson<String?>(photoPath),
      'qty': serializer.toJson<int>(qty),
      'rarity': serializer.toJson<String>(rarity),
      'notes': serializer.toJson<String?>(notes),
      'spot': serializer.toJson<String?>(spot),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ItemRow copyWith({
    int? id,
    int? boxId,
    String? name,
    String? category,
    String? iconKey,
    Value<String?> photoPath = const Value.absent(),
    int? qty,
    String? rarity,
    Value<String?> notes = const Value.absent(),
    Value<String?> spot = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ItemRow(
    id: id ?? this.id,
    boxId: boxId ?? this.boxId,
    name: name ?? this.name,
    category: category ?? this.category,
    iconKey: iconKey ?? this.iconKey,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    qty: qty ?? this.qty,
    rarity: rarity ?? this.rarity,
    notes: notes.present ? notes.value : this.notes,
    spot: spot.present ? spot.value : this.spot,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ItemRow copyWithCompanion(ItemsCompanion data) {
    return ItemRow(
      id: data.id.present ? data.id.value : this.id,
      boxId: data.boxId.present ? data.boxId.value : this.boxId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      qty: data.qty.present ? data.qty.value : this.qty,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      notes: data.notes.present ? data.notes.value : this.notes,
      spot: data.spot.present ? data.spot.value : this.spot,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('id: $id, ')
          ..write('boxId: $boxId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('iconKey: $iconKey, ')
          ..write('photoPath: $photoPath, ')
          ..write('qty: $qty, ')
          ..write('rarity: $rarity, ')
          ..write('notes: $notes, ')
          ..write('spot: $spot, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    boxId,
    name,
    category,
    iconKey,
    photoPath,
    qty,
    rarity,
    notes,
    spot,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.id == this.id &&
          other.boxId == this.boxId &&
          other.name == this.name &&
          other.category == this.category &&
          other.iconKey == this.iconKey &&
          other.photoPath == this.photoPath &&
          other.qty == this.qty &&
          other.rarity == this.rarity &&
          other.notes == this.notes &&
          other.spot == this.spot &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ItemsCompanion extends UpdateCompanion<ItemRow> {
  final Value<int> id;
  final Value<int> boxId;
  final Value<String> name;
  final Value<String> category;
  final Value<String> iconKey;
  final Value<String?> photoPath;
  final Value<int> qty;
  final Value<String> rarity;
  final Value<String?> notes;
  final Value<String?> spot;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.boxId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.qty = const Value.absent(),
    this.rarity = const Value.absent(),
    this.notes = const Value.absent(),
    this.spot = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.id = const Value.absent(),
    required int boxId,
    required String name,
    required String category,
    required String iconKey,
    this.photoPath = const Value.absent(),
    this.qty = const Value.absent(),
    this.rarity = const Value.absent(),
    this.notes = const Value.absent(),
    this.spot = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : boxId = Value(boxId),
       name = Value(name),
       category = Value(category),
       iconKey = Value(iconKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ItemRow> custom({
    Expression<int>? id,
    Expression<int>? boxId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? iconKey,
    Expression<String>? photoPath,
    Expression<int>? qty,
    Expression<String>? rarity,
    Expression<String>? notes,
    Expression<String>? spot,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boxId != null) 'box_id': boxId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (iconKey != null) 'icon_key': iconKey,
      if (photoPath != null) 'photo_path': photoPath,
      if (qty != null) 'qty': qty,
      if (rarity != null) 'rarity': rarity,
      if (notes != null) 'notes': notes,
      if (spot != null) 'spot': spot,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? boxId,
    Value<String>? name,
    Value<String>? category,
    Value<String>? iconKey,
    Value<String?>? photoPath,
    Value<int>? qty,
    Value<String>? rarity,
    Value<String?>? notes,
    Value<String?>? spot,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      boxId: boxId ?? this.boxId,
      name: name ?? this.name,
      category: category ?? this.category,
      iconKey: iconKey ?? this.iconKey,
      photoPath: photoPath ?? this.photoPath,
      qty: qty ?? this.qty,
      rarity: rarity ?? this.rarity,
      notes: notes ?? this.notes,
      spot: spot ?? this.spot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (boxId.present) {
      map['box_id'] = Variable<int>(boxId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (spot.present) {
      map['spot'] = Variable<String>(spot.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('boxId: $boxId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('iconKey: $iconKey, ')
          ..write('photoPath: $photoPath, ')
          ..write('qty: $qty, ')
          ..write('rarity: $rarity, ')
          ..write('notes: $notes, ')
          ..write('spot: $spot, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BoxesTable boxes = $BoxesTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final BoxesDao boxesDao = BoxesDao(this as AppDatabase);
  late final ItemsDao itemsDao = ItemsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [boxes, items];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'boxes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('items', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$BoxesTableCreateCompanionBuilder =
    BoxesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> capacity,
      Value<String?> nfcTagId,
      Value<String?> qrToken,
      Value<int> slot,
      Value<String> skinKey,
      Value<int> sortOrder,
      Value<DateTime?> qrUsedAt,
      Value<DateTime?> nfcUsedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$BoxesTableUpdateCompanionBuilder =
    BoxesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> capacity,
      Value<String?> nfcTagId,
      Value<String?> qrToken,
      Value<int> slot,
      Value<String> skinKey,
      Value<int> sortOrder,
      Value<DateTime?> qrUsedAt,
      Value<DateTime?> nfcUsedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$BoxesTableReferences
    extends BaseReferences<_$AppDatabase, $BoxesTable, BoxRow> {
  $$BoxesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemsTable, List<ItemRow>> _itemsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.items,
    aliasName: $_aliasNameGenerator(db.boxes.id, db.items.boxId),
  );

  $$ItemsTableProcessedTableManager get itemsRefs {
    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.boxId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BoxesTableFilterComposer extends Composer<_$AppDatabase, $BoxesTable> {
  $$BoxesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nfcTagId => $composableBuilder(
    column: $table.nfcTagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qrToken => $composableBuilder(
    column: $table.qrToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skinKey => $composableBuilder(
    column: $table.skinKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get qrUsedAt => $composableBuilder(
    column: $table.qrUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nfcUsedAt => $composableBuilder(
    column: $table.nfcUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> itemsRefs(
    Expression<bool> Function($$ItemsTableFilterComposer f) f,
  ) {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.boxId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BoxesTableOrderingComposer
    extends Composer<_$AppDatabase, $BoxesTable> {
  $$BoxesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nfcTagId => $composableBuilder(
    column: $table.nfcTagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qrToken => $composableBuilder(
    column: $table.qrToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skinKey => $composableBuilder(
    column: $table.skinKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get qrUsedAt => $composableBuilder(
    column: $table.qrUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nfcUsedAt => $composableBuilder(
    column: $table.nfcUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoxesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoxesTable> {
  $$BoxesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<String> get nfcTagId =>
      $composableBuilder(column: $table.nfcTagId, builder: (column) => column);

  GeneratedColumn<String> get qrToken =>
      $composableBuilder(column: $table.qrToken, builder: (column) => column);

  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get skinKey =>
      $composableBuilder(column: $table.skinKey, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get qrUsedAt =>
      $composableBuilder(column: $table.qrUsedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nfcUsedAt =>
      $composableBuilder(column: $table.nfcUsedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> itemsRefs<T extends Object>(
    Expression<T> Function($$ItemsTableAnnotationComposer a) f,
  ) {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.boxId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BoxesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoxesTable,
          BoxRow,
          $$BoxesTableFilterComposer,
          $$BoxesTableOrderingComposer,
          $$BoxesTableAnnotationComposer,
          $$BoxesTableCreateCompanionBuilder,
          $$BoxesTableUpdateCompanionBuilder,
          (BoxRow, $$BoxesTableReferences),
          BoxRow,
          PrefetchHooks Function({bool itemsRefs})
        > {
  $$BoxesTableTableManager(_$AppDatabase db, $BoxesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoxesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoxesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoxesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<String?> nfcTagId = const Value.absent(),
                Value<String?> qrToken = const Value.absent(),
                Value<int> slot = const Value.absent(),
                Value<String> skinKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime?> qrUsedAt = const Value.absent(),
                Value<DateTime?> nfcUsedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BoxesCompanion(
                id: id,
                name: name,
                capacity: capacity,
                nfcTagId: nfcTagId,
                qrToken: qrToken,
                slot: slot,
                skinKey: skinKey,
                sortOrder: sortOrder,
                qrUsedAt: qrUsedAt,
                nfcUsedAt: nfcUsedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<String?> nfcTagId = const Value.absent(),
                Value<String?> qrToken = const Value.absent(),
                Value<int> slot = const Value.absent(),
                Value<String> skinKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime?> qrUsedAt = const Value.absent(),
                Value<DateTime?> nfcUsedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => BoxesCompanion.insert(
                id: id,
                name: name,
                capacity: capacity,
                nfcTagId: nfcTagId,
                qrToken: qrToken,
                slot: slot,
                skinKey: skinKey,
                sortOrder: sortOrder,
                qrUsedAt: qrUsedAt,
                nfcUsedAt: nfcUsedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BoxesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({itemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemsRefs) db.items],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemsRefs)
                    await $_getPrefetchedData<BoxRow, $BoxesTable, ItemRow>(
                      currentTable: table,
                      referencedTable: $$BoxesTableReferences._itemsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$BoxesTableReferences(db, table, p0).itemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.boxId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BoxesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoxesTable,
      BoxRow,
      $$BoxesTableFilterComposer,
      $$BoxesTableOrderingComposer,
      $$BoxesTableAnnotationComposer,
      $$BoxesTableCreateCompanionBuilder,
      $$BoxesTableUpdateCompanionBuilder,
      (BoxRow, $$BoxesTableReferences),
      BoxRow,
      PrefetchHooks Function({bool itemsRefs})
    >;
typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      required int boxId,
      required String name,
      required String category,
      required String iconKey,
      Value<String?> photoPath,
      Value<int> qty,
      Value<String> rarity,
      Value<String?> notes,
      Value<String?> spot,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      Value<int> boxId,
      Value<String> name,
      Value<String> category,
      Value<String> iconKey,
      Value<String?> photoPath,
      Value<int> qty,
      Value<String> rarity,
      Value<String?> notes,
      Value<String?> spot,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, ItemRow> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BoxesTable _boxIdTable(_$AppDatabase db) =>
      db.boxes.createAlias($_aliasNameGenerator(db.items.boxId, db.boxes.id));

  $$BoxesTableProcessedTableManager get boxId {
    final $_column = $_itemColumn<int>('box_id')!;

    final manager = $$BoxesTableTableManager(
      $_db,
      $_db.boxes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_boxIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spot => $composableBuilder(
    column: $table.spot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BoxesTableFilterComposer get boxId {
    final $$BoxesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boxId,
      referencedTable: $db.boxes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoxesTableFilterComposer(
            $db: $db,
            $table: $db.boxes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spot => $composableBuilder(
    column: $table.spot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BoxesTableOrderingComposer get boxId {
    final $$BoxesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boxId,
      referencedTable: $db.boxes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoxesTableOrderingComposer(
            $db: $db,
            $table: $db.boxes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get spot =>
      $composableBuilder(column: $table.spot, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BoxesTableAnnotationComposer get boxId {
    final $$BoxesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boxId,
      referencedTable: $db.boxes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoxesTableAnnotationComposer(
            $db: $db,
            $table: $db.boxes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          ItemRow,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (ItemRow, $$ItemsTableReferences),
          ItemRow,
          PrefetchHooks Function({bool boxId})
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> boxId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<String> rarity = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> spot = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                boxId: boxId,
                name: name,
                category: category,
                iconKey: iconKey,
                photoPath: photoPath,
                qty: qty,
                rarity: rarity,
                notes: notes,
                spot: spot,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int boxId,
                required String name,
                required String category,
                required String iconKey,
                Value<String?> photoPath = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<String> rarity = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> spot = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ItemsCompanion.insert(
                id: id,
                boxId: boxId,
                name: name,
                category: category,
                iconKey: iconKey,
                photoPath: photoPath,
                qty: qty,
                rarity: rarity,
                notes: notes,
                spot: spot,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ItemsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({boxId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (boxId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.boxId,
                                referencedTable: $$ItemsTableReferences
                                    ._boxIdTable(db),
                                referencedColumn: $$ItemsTableReferences
                                    ._boxIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      ItemRow,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (ItemRow, $$ItemsTableReferences),
      ItemRow,
      PrefetchHooks Function({bool boxId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BoxesTableTableManager get boxes =>
      $$BoxesTableTableManager(_db, _db.boxes);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
}
