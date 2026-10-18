// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, MenuCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('coffee'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF8A5A36),
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
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    name,
    icon,
    color,
    sortOrder,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MenuCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MenuCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MenuCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class MenuCategory extends DataClass implements Insertable<MenuCategory> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String name;
  final String icon;
  final int color;
  final int sortOrder;
  final bool active;
  const MenuCategory({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.icon,
    required this.color,
    required this.sortOrder,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    map['active'] = Variable<bool>(active);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      sortOrder: Value(sortOrder),
      active: Value(active),
    );
  }

  factory MenuCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MenuCategory(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'active': serializer.toJson<bool>(active),
    };
  }

  MenuCategory copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? name,
    String? icon,
    int? color,
    int? sortOrder,
    bool? active,
  }) => MenuCategory(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    active: active ?? this.active,
  );
  MenuCategory copyWithCompanion(CategoriesCompanion data) {
    return MenuCategory(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MenuCategory(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, deleted, name, icon, color, sortOrder, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MenuCategory &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.active == this.active);
}

class CategoriesCompanion extends UpdateCompanion<MenuCategory> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> color;
  final Value<int> sortOrder;
  final Value<bool> active;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<MenuCategory> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<int>? sortOrder,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? color,
    Value<int>? sortOrder,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizesJsonMeta = const VerificationMeta(
    'sizesJson',
  );
  @override
  late final GeneratedColumn<String> sizesJson = GeneratedColumn<String>(
    'sizes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _modifierGroupIdsJsonMeta =
      const VerificationMeta('modifierGroupIdsJson');
  @override
  late final GeneratedColumn<String> modifierGroupIdsJson =
      GeneratedColumn<String>(
        'modifier_group_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _taxExemptMeta = const VerificationMeta(
    'taxExempt',
  );
  @override
  late final GeneratedColumn<bool> taxExempt = GeneratedColumn<bool>(
    'tax_exempt',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tax_exempt" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('coffee'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF8A5A36),
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
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _availableMeta = const VerificationMeta(
    'available',
  );
  @override
  late final GeneratedColumn<bool> available = GeneratedColumn<bool>(
    'available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _favouriteMeta = const VerificationMeta(
    'favourite',
  );
  @override
  late final GeneratedColumn<bool> favourite = GeneratedColumn<bool>(
    'favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    categoryId,
    name,
    description,
    price,
    sizesJson,
    modifierGroupIdsJson,
    taxExempt,
    icon,
    color,
    sortOrder,
    active,
    available,
    favourite,
    sku,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('sizes_json')) {
      context.handle(
        _sizesJsonMeta,
        sizesJson.isAcceptableOrUnknown(data['sizes_json']!, _sizesJsonMeta),
      );
    }
    if (data.containsKey('modifier_group_ids_json')) {
      context.handle(
        _modifierGroupIdsJsonMeta,
        modifierGroupIdsJson.isAcceptableOrUnknown(
          data['modifier_group_ids_json']!,
          _modifierGroupIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('tax_exempt')) {
      context.handle(
        _taxExemptMeta,
        taxExempt.isAcceptableOrUnknown(data['tax_exempt']!, _taxExemptMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('available')) {
      context.handle(
        _availableMeta,
        available.isAcceptableOrUnknown(data['available']!, _availableMeta),
      );
    }
    if (data.containsKey('favourite')) {
      context.handle(
        _favouriteMeta,
        favourite.isAcceptableOrUnknown(data['favourite']!, _favouriteMeta),
      );
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price'],
      )!,
      sizesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sizes_json'],
      )!,
      modifierGroupIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modifier_group_ids_json'],
      )!,
      taxExempt: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tax_exempt'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      available: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}available'],
      )!,
      favourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favourite'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String categoryId;
  final String name;
  final String? description;

  /// Base price in paisa (for the default/first size).
  final int price;

  /// JSON list: [{"code":"S","label":"Small","delta":-5000}]
  final String sizesJson;

  /// JSON list of modifier group ids.
  final String modifierGroupIdsJson;
  final bool taxExempt;
  final String icon;
  final int color;
  final int sortOrder;
  final bool active;

  /// False when "86'd" (sold out today).
  final bool available;
  final bool favourite;
  final String? sku;
  const Product({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    required this.sizesJson,
    required this.modifierGroupIdsJson,
    required this.taxExempt,
    required this.icon,
    required this.color,
    required this.sortOrder,
    required this.active,
    required this.available,
    required this.favourite,
    this.sku,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['price'] = Variable<int>(price);
    map['sizes_json'] = Variable<String>(sizesJson);
    map['modifier_group_ids_json'] = Variable<String>(modifierGroupIdsJson);
    map['tax_exempt'] = Variable<bool>(taxExempt);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    map['active'] = Variable<bool>(active);
    map['available'] = Variable<bool>(available);
    map['favourite'] = Variable<bool>(favourite);
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      categoryId: Value(categoryId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      price: Value(price),
      sizesJson: Value(sizesJson),
      modifierGroupIdsJson: Value(modifierGroupIdsJson),
      taxExempt: Value(taxExempt),
      icon: Value(icon),
      color: Value(color),
      sortOrder: Value(sortOrder),
      active: Value(active),
      available: Value(available),
      favourite: Value(favourite),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      price: serializer.fromJson<int>(json['price']),
      sizesJson: serializer.fromJson<String>(json['sizesJson']),
      modifierGroupIdsJson: serializer.fromJson<String>(
        json['modifierGroupIdsJson'],
      ),
      taxExempt: serializer.fromJson<bool>(json['taxExempt']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      active: serializer.fromJson<bool>(json['active']),
      available: serializer.fromJson<bool>(json['available']),
      favourite: serializer.fromJson<bool>(json['favourite']),
      sku: serializer.fromJson<String?>(json['sku']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'categoryId': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'price': serializer.toJson<int>(price),
      'sizesJson': serializer.toJson<String>(sizesJson),
      'modifierGroupIdsJson': serializer.toJson<String>(modifierGroupIdsJson),
      'taxExempt': serializer.toJson<bool>(taxExempt),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'active': serializer.toJson<bool>(active),
      'available': serializer.toJson<bool>(available),
      'favourite': serializer.toJson<bool>(favourite),
      'sku': serializer.toJson<String?>(sku),
    };
  }

  Product copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? categoryId,
    String? name,
    Value<String?> description = const Value.absent(),
    int? price,
    String? sizesJson,
    String? modifierGroupIdsJson,
    bool? taxExempt,
    String? icon,
    int? color,
    int? sortOrder,
    bool? active,
    bool? available,
    bool? favourite,
    Value<String?> sku = const Value.absent(),
  }) => Product(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    price: price ?? this.price,
    sizesJson: sizesJson ?? this.sizesJson,
    modifierGroupIdsJson: modifierGroupIdsJson ?? this.modifierGroupIdsJson,
    taxExempt: taxExempt ?? this.taxExempt,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    active: active ?? this.active,
    available: available ?? this.available,
    favourite: favourite ?? this.favourite,
    sku: sku.present ? sku.value : this.sku,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      price: data.price.present ? data.price.value : this.price,
      sizesJson: data.sizesJson.present ? data.sizesJson.value : this.sizesJson,
      modifierGroupIdsJson: data.modifierGroupIdsJson.present
          ? data.modifierGroupIdsJson.value
          : this.modifierGroupIdsJson,
      taxExempt: data.taxExempt.present ? data.taxExempt.value : this.taxExempt,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      active: data.active.present ? data.active.value : this.active,
      available: data.available.present ? data.available.value : this.available,
      favourite: data.favourite.present ? data.favourite.value : this.favourite,
      sku: data.sku.present ? data.sku.value : this.sku,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('sizesJson: $sizesJson, ')
          ..write('modifierGroupIdsJson: $modifierGroupIdsJson, ')
          ..write('taxExempt: $taxExempt, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('active: $active, ')
          ..write('available: $available, ')
          ..write('favourite: $favourite, ')
          ..write('sku: $sku')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    categoryId,
    name,
    description,
    price,
    sizesJson,
    modifierGroupIdsJson,
    taxExempt,
    icon,
    color,
    sortOrder,
    active,
    available,
    favourite,
    sku,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.description == this.description &&
          other.price == this.price &&
          other.sizesJson == this.sizesJson &&
          other.modifierGroupIdsJson == this.modifierGroupIdsJson &&
          other.taxExempt == this.taxExempt &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.active == this.active &&
          other.available == this.available &&
          other.favourite == this.favourite &&
          other.sku == this.sku);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> price;
  final Value<String> sizesJson;
  final Value<String> modifierGroupIdsJson;
  final Value<bool> taxExempt;
  final Value<String> icon;
  final Value<int> color;
  final Value<int> sortOrder;
  final Value<bool> active;
  final Value<bool> available;
  final Value<bool> favourite;
  final Value<String?> sku;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.sizesJson = const Value.absent(),
    this.modifierGroupIdsJson = const Value.absent(),
    this.taxExempt = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.active = const Value.absent(),
    this.available = const Value.absent(),
    this.favourite = const Value.absent(),
    this.sku = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String categoryId,
    required String name,
    this.description = const Value.absent(),
    required int price,
    this.sizesJson = const Value.absent(),
    this.modifierGroupIdsJson = const Value.absent(),
    this.taxExempt = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.active = const Value.absent(),
    this.available = const Value.absent(),
    this.favourite = const Value.absent(),
    this.sku = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       categoryId = Value(categoryId),
       name = Value(name),
       price = Value(price);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? price,
    Expression<String>? sizesJson,
    Expression<String>? modifierGroupIdsJson,
    Expression<bool>? taxExempt,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<int>? sortOrder,
    Expression<bool>? active,
    Expression<bool>? available,
    Expression<bool>? favourite,
    Expression<String>? sku,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (sizesJson != null) 'sizes_json': sizesJson,
      if (modifierGroupIdsJson != null)
        'modifier_group_ids_json': modifierGroupIdsJson,
      if (taxExempt != null) 'tax_exempt': taxExempt,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (active != null) 'active': active,
      if (available != null) 'available': available,
      if (favourite != null) 'favourite': favourite,
      if (sku != null) 'sku': sku,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? categoryId,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? price,
    Value<String>? sizesJson,
    Value<String>? modifierGroupIdsJson,
    Value<bool>? taxExempt,
    Value<String>? icon,
    Value<int>? color,
    Value<int>? sortOrder,
    Value<bool>? active,
    Value<bool>? available,
    Value<bool>? favourite,
    Value<String?>? sku,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      sizesJson: sizesJson ?? this.sizesJson,
      modifierGroupIdsJson: modifierGroupIdsJson ?? this.modifierGroupIdsJson,
      taxExempt: taxExempt ?? this.taxExempt,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
      available: available ?? this.available,
      favourite: favourite ?? this.favourite,
      sku: sku ?? this.sku,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (sizesJson.present) {
      map['sizes_json'] = Variable<String>(sizesJson.value);
    }
    if (modifierGroupIdsJson.present) {
      map['modifier_group_ids_json'] = Variable<String>(
        modifierGroupIdsJson.value,
      );
    }
    if (taxExempt.present) {
      map['tax_exempt'] = Variable<bool>(taxExempt.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (available.present) {
      map['available'] = Variable<bool>(available.value);
    }
    if (favourite.present) {
      map['favourite'] = Variable<bool>(favourite.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('sizesJson: $sizesJson, ')
          ..write('modifierGroupIdsJson: $modifierGroupIdsJson, ')
          ..write('taxExempt: $taxExempt, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('active: $active, ')
          ..write('available: $available, ')
          ..write('favourite: $favourite, ')
          ..write('sku: $sku, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModifierGroupsTable extends ModifierGroups
    with TableInfo<$ModifierGroupsTable, ModifierGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModifierGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minSelectMeta = const VerificationMeta(
    'minSelect',
  );
  @override
  late final GeneratedColumn<int> minSelect = GeneratedColumn<int>(
    'min_select',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxSelectMeta = const VerificationMeta(
    'maxSelect',
  );
  @override
  late final GeneratedColumn<int> maxSelect = GeneratedColumn<int>(
    'max_select',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _optionsJsonMeta = const VerificationMeta(
    'optionsJson',
  );
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
    'options_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    name,
    minSelect,
    maxSelect,
    optionsJson,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'modifier_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModifierGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('min_select')) {
      context.handle(
        _minSelectMeta,
        minSelect.isAcceptableOrUnknown(data['min_select']!, _minSelectMeta),
      );
    }
    if (data.containsKey('max_select')) {
      context.handle(
        _maxSelectMeta,
        maxSelect.isAcceptableOrUnknown(data['max_select']!, _maxSelectMeta),
      );
    }
    if (data.containsKey('options_json')) {
      context.handle(
        _optionsJsonMeta,
        optionsJson.isAcceptableOrUnknown(
          data['options_json']!,
          _optionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModifierGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModifierGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      minSelect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_select'],
      )!,
      maxSelect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_select'],
      )!,
      optionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options_json'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ModifierGroupsTable createAlias(String alias) {
    return $ModifierGroupsTable(attachedDatabase, alias);
  }
}

class ModifierGroup extends DataClass implements Insertable<ModifierGroup> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String name;
  final int minSelect;
  final int maxSelect;

  /// JSON list: [{"id":"oat","name":"Oat milk","delta":15000,
  ///   "stockItemId":"oat","qty":200,"replacesStockItemId":"milk"}]
  final String optionsJson;
  final int sortOrder;
  const ModifierGroup({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.minSelect,
    required this.maxSelect,
    required this.optionsJson,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['min_select'] = Variable<int>(minSelect);
    map['max_select'] = Variable<int>(maxSelect);
    map['options_json'] = Variable<String>(optionsJson);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ModifierGroupsCompanion toCompanion(bool nullToAbsent) {
    return ModifierGroupsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      minSelect: Value(minSelect),
      maxSelect: Value(maxSelect),
      optionsJson: Value(optionsJson),
      sortOrder: Value(sortOrder),
    );
  }

  factory ModifierGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModifierGroup(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      minSelect: serializer.fromJson<int>(json['minSelect']),
      maxSelect: serializer.fromJson<int>(json['maxSelect']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'minSelect': serializer.toJson<int>(minSelect),
      'maxSelect': serializer.toJson<int>(maxSelect),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ModifierGroup copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? name,
    int? minSelect,
    int? maxSelect,
    String? optionsJson,
    int? sortOrder,
  }) => ModifierGroup(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    minSelect: minSelect ?? this.minSelect,
    maxSelect: maxSelect ?? this.maxSelect,
    optionsJson: optionsJson ?? this.optionsJson,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ModifierGroup copyWithCompanion(ModifierGroupsCompanion data) {
    return ModifierGroup(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      minSelect: data.minSelect.present ? data.minSelect.value : this.minSelect,
      maxSelect: data.maxSelect.present ? data.maxSelect.value : this.maxSelect,
      optionsJson: data.optionsJson.present
          ? data.optionsJson.value
          : this.optionsJson,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModifierGroup(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('minSelect: $minSelect, ')
          ..write('maxSelect: $maxSelect, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    name,
    minSelect,
    maxSelect,
    optionsJson,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModifierGroup &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.minSelect == this.minSelect &&
          other.maxSelect == this.maxSelect &&
          other.optionsJson == this.optionsJson &&
          other.sortOrder == this.sortOrder);
}

class ModifierGroupsCompanion extends UpdateCompanion<ModifierGroup> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<int> minSelect;
  final Value<int> maxSelect;
  final Value<String> optionsJson;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ModifierGroupsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.minSelect = const Value.absent(),
    this.maxSelect = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModifierGroupsCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    this.minSelect = const Value.absent(),
    this.maxSelect = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<ModifierGroup> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<int>? minSelect,
    Expression<int>? maxSelect,
    Expression<String>? optionsJson,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (minSelect != null) 'min_select': minSelect,
      if (maxSelect != null) 'max_select': maxSelect,
      if (optionsJson != null) 'options_json': optionsJson,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModifierGroupsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<int>? minSelect,
    Value<int>? maxSelect,
    Value<String>? optionsJson,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ModifierGroupsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      minSelect: minSelect ?? this.minSelect,
      maxSelect: maxSelect ?? this.maxSelect,
      optionsJson: optionsJson ?? this.optionsJson,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (minSelect.present) {
      map['min_select'] = Variable<int>(minSelect.value);
    }
    if (maxSelect.present) {
      map['max_select'] = Variable<int>(maxSelect.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModifierGroupsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('minSelect: $minSelect, ')
          ..write('maxSelect: $maxSelect, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaxesTable extends Taxes with TableInfo<$TaxesTable, TaxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaxesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _cashBpMeta = const VerificationMeta('cashBp');
  @override
  late final GeneratedColumn<int> cashBp = GeneratedColumn<int>(
    'cash_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardOnlineBpMeta = const VerificationMeta(
    'cardOnlineBp',
  );
  @override
  late final GeneratedColumn<int> cardOnlineBp = GeneratedColumn<int>(
    'card_online_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _builtInMeta = const VerificationMeta(
    'builtIn',
  );
  @override
  late final GeneratedColumn<bool> builtIn = GeneratedColumn<bool>(
    'built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    name,
    enabled,
    cashBp,
    cardOnlineBp,
    builtIn,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'taxes';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('cash_bp')) {
      context.handle(
        _cashBpMeta,
        cashBp.isAcceptableOrUnknown(data['cash_bp']!, _cashBpMeta),
      );
    } else if (isInserting) {
      context.missing(_cashBpMeta);
    }
    if (data.containsKey('card_online_bp')) {
      context.handle(
        _cardOnlineBpMeta,
        cardOnlineBp.isAcceptableOrUnknown(
          data['card_online_bp']!,
          _cardOnlineBpMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cardOnlineBpMeta);
    }
    if (data.containsKey('built_in')) {
      context.handle(
        _builtInMeta,
        builtIn.isAcceptableOrUnknown(data['built_in']!, _builtInMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaxRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      cashBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cash_bp'],
      )!,
      cardOnlineBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_online_bp'],
      )!,
      builtIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}built_in'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $TaxesTable createAlias(String alias) {
    return $TaxesTable(attachedDatabase, alias);
  }
}

class TaxRow extends DataClass implements Insertable<TaxRow> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String name;
  final bool enabled;
  final int cashBp;
  final int cardOnlineBp;

  /// GST is built in: its name is fixed and it can't be deleted.
  final bool builtIn;
  final int sortOrder;
  const TaxRow({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.enabled,
    required this.cashBp,
    required this.cardOnlineBp,
    required this.builtIn,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['enabled'] = Variable<bool>(enabled);
    map['cash_bp'] = Variable<int>(cashBp);
    map['card_online_bp'] = Variable<int>(cardOnlineBp);
    map['built_in'] = Variable<bool>(builtIn);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TaxesCompanion toCompanion(bool nullToAbsent) {
    return TaxesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      enabled: Value(enabled),
      cashBp: Value(cashBp),
      cardOnlineBp: Value(cardOnlineBp),
      builtIn: Value(builtIn),
      sortOrder: Value(sortOrder),
    );
  }

  factory TaxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaxRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      cashBp: serializer.fromJson<int>(json['cashBp']),
      cardOnlineBp: serializer.fromJson<int>(json['cardOnlineBp']),
      builtIn: serializer.fromJson<bool>(json['builtIn']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'enabled': serializer.toJson<bool>(enabled),
      'cashBp': serializer.toJson<int>(cashBp),
      'cardOnlineBp': serializer.toJson<int>(cardOnlineBp),
      'builtIn': serializer.toJson<bool>(builtIn),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TaxRow copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? name,
    bool? enabled,
    int? cashBp,
    int? cardOnlineBp,
    bool? builtIn,
    int? sortOrder,
  }) => TaxRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    enabled: enabled ?? this.enabled,
    cashBp: cashBp ?? this.cashBp,
    cardOnlineBp: cardOnlineBp ?? this.cardOnlineBp,
    builtIn: builtIn ?? this.builtIn,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  TaxRow copyWithCompanion(TaxesCompanion data) {
    return TaxRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      cashBp: data.cashBp.present ? data.cashBp.value : this.cashBp,
      cardOnlineBp: data.cardOnlineBp.present
          ? data.cardOnlineBp.value
          : this.cardOnlineBp,
      builtIn: data.builtIn.present ? data.builtIn.value : this.builtIn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaxRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('enabled: $enabled, ')
          ..write('cashBp: $cashBp, ')
          ..write('cardOnlineBp: $cardOnlineBp, ')
          ..write('builtIn: $builtIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    name,
    enabled,
    cashBp,
    cardOnlineBp,
    builtIn,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaxRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.enabled == this.enabled &&
          other.cashBp == this.cashBp &&
          other.cardOnlineBp == this.cardOnlineBp &&
          other.builtIn == this.builtIn &&
          other.sortOrder == this.sortOrder);
}

class TaxesCompanion extends UpdateCompanion<TaxRow> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<bool> enabled;
  final Value<int> cashBp;
  final Value<int> cardOnlineBp;
  final Value<bool> builtIn;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const TaxesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.enabled = const Value.absent(),
    this.cashBp = const Value.absent(),
    this.cardOnlineBp = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaxesCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    this.enabled = const Value.absent(),
    required int cashBp,
    required int cardOnlineBp,
    this.builtIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       name = Value(name),
       cashBp = Value(cashBp),
       cardOnlineBp = Value(cardOnlineBp);
  static Insertable<TaxRow> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<bool>? enabled,
    Expression<int>? cashBp,
    Expression<int>? cardOnlineBp,
    Expression<bool>? builtIn,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (enabled != null) 'enabled': enabled,
      if (cashBp != null) 'cash_bp': cashBp,
      if (cardOnlineBp != null) 'card_online_bp': cardOnlineBp,
      if (builtIn != null) 'built_in': builtIn,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaxesCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<bool>? enabled,
    Value<int>? cashBp,
    Value<int>? cardOnlineBp,
    Value<bool>? builtIn,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return TaxesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      cashBp: cashBp ?? this.cashBp,
      cardOnlineBp: cardOnlineBp ?? this.cardOnlineBp,
      builtIn: builtIn ?? this.builtIn,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (cashBp.present) {
      map['cash_bp'] = Variable<int>(cashBp.value);
    }
    if (cardOnlineBp.present) {
      map['card_online_bp'] = Variable<int>(cardOnlineBp.value);
    }
    if (builtIn.present) {
      map['built_in'] = Variable<bool>(builtIn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaxesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('enabled: $enabled, ')
          ..write('cashBp: $cashBp, ')
          ..write('cardOnlineBp: $cardOnlineBp, ')
          ..write('builtIn: $builtIn, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentMethodsTable extends PaymentMethods
    with TableInfo<$PaymentMethodsTable, PaymentMethod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentMethodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateGroupMeta = const VerificationMeta(
    'rateGroup',
  );
  @override
  late final GeneratedColumn<String> rateGroup = GeneratedColumn<String>(
    'rate_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('payments'),
  );
  static const VerificationMeta _opensDrawerMeta = const VerificationMeta(
    'opensDrawer',
  );
  @override
  late final GeneratedColumn<bool> opensDrawer = GeneratedColumn<bool>(
    'opens_drawer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("opens_drawer" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _builtInMeta = const VerificationMeta(
    'builtIn',
  );
  @override
  late final GeneratedColumn<bool> builtIn = GeneratedColumn<bool>(
    'built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    name,
    rateGroup,
    icon,
    opensDrawer,
    active,
    builtIn,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_methods';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentMethod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rate_group')) {
      context.handle(
        _rateGroupMeta,
        rateGroup.isAcceptableOrUnknown(data['rate_group']!, _rateGroupMeta),
      );
    } else if (isInserting) {
      context.missing(_rateGroupMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('opens_drawer')) {
      context.handle(
        _opensDrawerMeta,
        opensDrawer.isAcceptableOrUnknown(
          data['opens_drawer']!,
          _opensDrawerMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('built_in')) {
      context.handle(
        _builtInMeta,
        builtIn.isAcceptableOrUnknown(data['built_in']!, _builtInMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentMethod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentMethod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rateGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_group'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      opensDrawer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}opens_drawer'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      builtIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}built_in'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PaymentMethodsTable createAlias(String alias) {
    return $PaymentMethodsTable(attachedDatabase, alias);
  }
}

class PaymentMethod extends DataClass implements Insertable<PaymentMethod> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String name;

  /// 'cash' or 'cardOnline'.
  final String rateGroup;
  final String icon;
  final bool opensDrawer;
  final bool active;
  final bool builtIn;
  final int sortOrder;
  const PaymentMethod({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.rateGroup,
    required this.icon,
    required this.opensDrawer,
    required this.active,
    required this.builtIn,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['rate_group'] = Variable<String>(rateGroup);
    map['icon'] = Variable<String>(icon);
    map['opens_drawer'] = Variable<bool>(opensDrawer);
    map['active'] = Variable<bool>(active);
    map['built_in'] = Variable<bool>(builtIn);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PaymentMethodsCompanion toCompanion(bool nullToAbsent) {
    return PaymentMethodsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      rateGroup: Value(rateGroup),
      icon: Value(icon),
      opensDrawer: Value(opensDrawer),
      active: Value(active),
      builtIn: Value(builtIn),
      sortOrder: Value(sortOrder),
    );
  }

  factory PaymentMethod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentMethod(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      rateGroup: serializer.fromJson<String>(json['rateGroup']),
      icon: serializer.fromJson<String>(json['icon']),
      opensDrawer: serializer.fromJson<bool>(json['opensDrawer']),
      active: serializer.fromJson<bool>(json['active']),
      builtIn: serializer.fromJson<bool>(json['builtIn']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'rateGroup': serializer.toJson<String>(rateGroup),
      'icon': serializer.toJson<String>(icon),
      'opensDrawer': serializer.toJson<bool>(opensDrawer),
      'active': serializer.toJson<bool>(active),
      'builtIn': serializer.toJson<bool>(builtIn),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PaymentMethod copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? name,
    String? rateGroup,
    String? icon,
    bool? opensDrawer,
    bool? active,
    bool? builtIn,
    int? sortOrder,
  }) => PaymentMethod(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    rateGroup: rateGroup ?? this.rateGroup,
    icon: icon ?? this.icon,
    opensDrawer: opensDrawer ?? this.opensDrawer,
    active: active ?? this.active,
    builtIn: builtIn ?? this.builtIn,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  PaymentMethod copyWithCompanion(PaymentMethodsCompanion data) {
    return PaymentMethod(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      rateGroup: data.rateGroup.present ? data.rateGroup.value : this.rateGroup,
      icon: data.icon.present ? data.icon.value : this.icon,
      opensDrawer: data.opensDrawer.present
          ? data.opensDrawer.value
          : this.opensDrawer,
      active: data.active.present ? data.active.value : this.active,
      builtIn: data.builtIn.present ? data.builtIn.value : this.builtIn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethod(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('rateGroup: $rateGroup, ')
          ..write('icon: $icon, ')
          ..write('opensDrawer: $opensDrawer, ')
          ..write('active: $active, ')
          ..write('builtIn: $builtIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    name,
    rateGroup,
    icon,
    opensDrawer,
    active,
    builtIn,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentMethod &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.rateGroup == this.rateGroup &&
          other.icon == this.icon &&
          other.opensDrawer == this.opensDrawer &&
          other.active == this.active &&
          other.builtIn == this.builtIn &&
          other.sortOrder == this.sortOrder);
}

class PaymentMethodsCompanion extends UpdateCompanion<PaymentMethod> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> rateGroup;
  final Value<String> icon;
  final Value<bool> opensDrawer;
  final Value<bool> active;
  final Value<bool> builtIn;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PaymentMethodsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.rateGroup = const Value.absent(),
    this.icon = const Value.absent(),
    this.opensDrawer = const Value.absent(),
    this.active = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentMethodsCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    required String rateGroup,
    this.icon = const Value.absent(),
    this.opensDrawer = const Value.absent(),
    this.active = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       name = Value(name),
       rateGroup = Value(rateGroup);
  static Insertable<PaymentMethod> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? rateGroup,
    Expression<String>? icon,
    Expression<bool>? opensDrawer,
    Expression<bool>? active,
    Expression<bool>? builtIn,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (rateGroup != null) 'rate_group': rateGroup,
      if (icon != null) 'icon': icon,
      if (opensDrawer != null) 'opens_drawer': opensDrawer,
      if (active != null) 'active': active,
      if (builtIn != null) 'built_in': builtIn,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentMethodsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? rateGroup,
    Value<String>? icon,
    Value<bool>? opensDrawer,
    Value<bool>? active,
    Value<bool>? builtIn,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return PaymentMethodsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      rateGroup: rateGroup ?? this.rateGroup,
      icon: icon ?? this.icon,
      opensDrawer: opensDrawer ?? this.opensDrawer,
      active: active ?? this.active,
      builtIn: builtIn ?? this.builtIn,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rateGroup.present) {
      map['rate_group'] = Variable<String>(rateGroup.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (opensDrawer.present) {
      map['opens_drawer'] = Variable<bool>(opensDrawer.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (builtIn.present) {
      map['built_in'] = Variable<bool>(builtIn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethodsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('rateGroup: $rateGroup, ')
          ..write('icon: $icon, ')
          ..write('opensDrawer: $opensDrawer, ')
          ..write('active: $active, ')
          ..write('builtIn: $builtIn, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AreasTable extends Areas with TableInfo<$AreasTable, Area> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AreasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    name,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'areas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Area> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Area map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Area(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $AreasTable createAlias(String alias) {
    return $AreasTable(attachedDatabase, alias);
  }
}

class Area extends DataClass implements Insertable<Area> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String name;
  final int sortOrder;
  const Area({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  AreasCompanion toCompanion(bool nullToAbsent) {
    return AreasCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory Area.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Area(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Area copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? name,
    int? sortOrder,
  }) => Area(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Area copyWithCompanion(AreasCompanion data) {
    return Area(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Area(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deleted, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Area &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class AreasCompanion extends UpdateCompanion<Area> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const AreasCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AreasCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<Area> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AreasCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return AreasCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AreasCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiningTablesTable extends DiningTables
    with TableInfo<$DiningTablesTable, DiningTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiningTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seatsMeta = const VerificationMeta('seats');
  @override
  late final GeneratedColumn<int> seats = GeneratedColumn<int>(
    'seats',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
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
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    areaId,
    label,
    seats,
    sortOrder,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dining_tables';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiningTable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_areaIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('seats')) {
      context.handle(
        _seatsMeta,
        seats.isAcceptableOrUnknown(data['seats']!, _seatsMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiningTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiningTable(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      seats: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seats'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $DiningTablesTable createAlias(String alias) {
    return $DiningTablesTable(attachedDatabase, alias);
  }
}

class DiningTable extends DataClass implements Insertable<DiningTable> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String areaId;
  final String label;
  final int seats;
  final int sortOrder;
  final bool active;
  const DiningTable({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.areaId,
    required this.label,
    required this.seats,
    required this.sortOrder,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['area_id'] = Variable<String>(areaId);
    map['label'] = Variable<String>(label);
    map['seats'] = Variable<int>(seats);
    map['sort_order'] = Variable<int>(sortOrder);
    map['active'] = Variable<bool>(active);
    return map;
  }

  DiningTablesCompanion toCompanion(bool nullToAbsent) {
    return DiningTablesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      areaId: Value(areaId),
      label: Value(label),
      seats: Value(seats),
      sortOrder: Value(sortOrder),
      active: Value(active),
    );
  }

  factory DiningTable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiningTable(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      areaId: serializer.fromJson<String>(json['areaId']),
      label: serializer.fromJson<String>(json['label']),
      seats: serializer.fromJson<int>(json['seats']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'areaId': serializer.toJson<String>(areaId),
      'label': serializer.toJson<String>(label),
      'seats': serializer.toJson<int>(seats),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'active': serializer.toJson<bool>(active),
    };
  }

  DiningTable copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? areaId,
    String? label,
    int? seats,
    int? sortOrder,
    bool? active,
  }) => DiningTable(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    areaId: areaId ?? this.areaId,
    label: label ?? this.label,
    seats: seats ?? this.seats,
    sortOrder: sortOrder ?? this.sortOrder,
    active: active ?? this.active,
  );
  DiningTable copyWithCompanion(DiningTablesCompanion data) {
    return DiningTable(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      label: data.label.present ? data.label.value : this.label,
      seats: data.seats.present ? data.seats.value : this.seats,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiningTable(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('areaId: $areaId, ')
          ..write('label: $label, ')
          ..write('seats: $seats, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    areaId,
    label,
    seats,
    sortOrder,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiningTable &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.areaId == this.areaId &&
          other.label == this.label &&
          other.seats == this.seats &&
          other.sortOrder == this.sortOrder &&
          other.active == this.active);
}

class DiningTablesCompanion extends UpdateCompanion<DiningTable> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> areaId;
  final Value<String> label;
  final Value<int> seats;
  final Value<int> sortOrder;
  final Value<bool> active;
  final Value<int> rowid;
  const DiningTablesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.areaId = const Value.absent(),
    this.label = const Value.absent(),
    this.seats = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiningTablesCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String areaId,
    required String label,
    this.seats = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       areaId = Value(areaId),
       label = Value(label);
  static Insertable<DiningTable> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? areaId,
    Expression<String>? label,
    Expression<int>? seats,
    Expression<int>? sortOrder,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (areaId != null) 'area_id': areaId,
      if (label != null) 'label': label,
      if (seats != null) 'seats': seats,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiningTablesCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? areaId,
    Value<String>? label,
    Value<int>? seats,
    Value<int>? sortOrder,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return DiningTablesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      areaId: areaId ?? this.areaId,
      label: label ?? this.label,
      seats: seats ?? this.seats,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (seats.present) {
      map['seats'] = Variable<int>(seats.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiningTablesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('areaId: $areaId, ')
          ..write('label: $label, ')
          ..write('seats: $seats, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaffTable extends Staff with TableInfo<$StaffTable, StaffMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinSaltMeta = const VerificationMeta(
    'pinSalt',
  );
  @override
  late final GeneratedColumn<String> pinSalt = GeneratedColumn<String>(
    'pin_salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF4E5726),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    name,
    role,
    pinHash,
    pinSalt,
    active,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaffMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    } else if (isInserting) {
      context.missing(_pinHashMeta);
    }
    if (data.containsKey('pin_salt')) {
      context.handle(
        _pinSaltMeta,
        pinSalt.isAcceptableOrUnknown(data['pin_salt']!, _pinSaltMeta),
      );
    } else if (isInserting) {
      context.missing(_pinSaltMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      )!,
      pinSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_salt'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $StaffTable createAlias(String alias) {
    return $StaffTable(attachedDatabase, alias);
  }
}

class StaffMember extends DataClass implements Insertable<StaffMember> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String name;

  /// 'owner' | 'manager' | 'cashier'
  final String role;
  final String pinHash;
  final String pinSalt;
  final bool active;
  final int color;
  const StaffMember({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.role,
    required this.pinHash,
    required this.pinSalt,
    required this.active,
    required this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    map['pin_hash'] = Variable<String>(pinHash);
    map['pin_salt'] = Variable<String>(pinSalt);
    map['active'] = Variable<bool>(active);
    map['color'] = Variable<int>(color);
    return map;
  }

  StaffCompanion toCompanion(bool nullToAbsent) {
    return StaffCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      role: Value(role),
      pinHash: Value(pinHash),
      pinSalt: Value(pinSalt),
      active: Value(active),
      color: Value(color),
    );
  }

  factory StaffMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffMember(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      pinHash: serializer.fromJson<String>(json['pinHash']),
      pinSalt: serializer.fromJson<String>(json['pinSalt']),
      active: serializer.fromJson<bool>(json['active']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'pinHash': serializer.toJson<String>(pinHash),
      'pinSalt': serializer.toJson<String>(pinSalt),
      'active': serializer.toJson<bool>(active),
      'color': serializer.toJson<int>(color),
    };
  }

  StaffMember copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? name,
    String? role,
    String? pinHash,
    String? pinSalt,
    bool? active,
    int? color,
  }) => StaffMember(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    role: role ?? this.role,
    pinHash: pinHash ?? this.pinHash,
    pinSalt: pinSalt ?? this.pinSalt,
    active: active ?? this.active,
    color: color ?? this.color,
  );
  StaffMember copyWithCompanion(StaffCompanion data) {
    return StaffMember(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      pinSalt: data.pinSalt.present ? data.pinSalt.value : this.pinSalt,
      active: data.active.present ? data.active.value : this.active,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffMember(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('active: $active, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    name,
    role,
    pinHash,
    pinSalt,
    active,
    color,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffMember &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.role == this.role &&
          other.pinHash == this.pinHash &&
          other.pinSalt == this.pinSalt &&
          other.active == this.active &&
          other.color == this.color);
}

class StaffCompanion extends UpdateCompanion<StaffMember> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> role;
  final Value<String> pinHash;
  final Value<String> pinSalt;
  final Value<bool> active;
  final Value<int> color;
  final Value<int> rowid;
  const StaffCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.active = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    required String role,
    required String pinHash,
    required String pinSalt,
    this.active = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       name = Value(name),
       role = Value(role),
       pinHash = Value(pinHash),
       pinSalt = Value(pinSalt);
  static Insertable<StaffMember> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? pinHash,
    Expression<String>? pinSalt,
    Expression<bool>? active,
    Expression<int>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (pinHash != null) 'pin_hash': pinHash,
      if (pinSalt != null) 'pin_salt': pinSalt,
      if (active != null) 'active': active,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? role,
    Value<String>? pinHash,
    Value<String>? pinSalt,
    Value<bool>? active,
    Value<int>? color,
    Value<int>? rowid,
  }) {
    return StaffCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      role: role ?? this.role,
      pinHash: pinHash ?? this.pinHash,
      pinSalt: pinSalt ?? this.pinSalt,
      active: active ?? this.active,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (pinSalt.present) {
      map['pin_salt'] = Variable<String>(pinSalt.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('active: $active, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    name,
    phone,
    address,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String name;
  final String phone;
  final String? address;
  final String? notes;
  final int createdAt;
  const Customer({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.phone,
    this.address,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      phone: Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'address': serializer.toJson<String?>(address),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Customer copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? name,
    String? phone,
    Value<String?> address = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? createdAt,
  }) => Customer(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    address: address.present ? address.value : this.address,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    name,
    phone,
    address,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> address;
  final Value<String?> notes;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? phone,
    Value<String?>? address,
    Value<String?>? notes,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<int> token = GeneratedColumn<int>(
    'token',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderTypeMeta = const VerificationMeta(
    'orderType',
  );
  @override
  late final GeneratedColumn<String> orderType = GeneratedColumn<String>(
    'order_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableIdMeta = const VerificationMeta(
    'tableId',
  );
  @override
  late final GeneratedColumn<String> tableId = GeneratedColumn<String>(
    'table_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tableLabelMeta = const VerificationMeta(
    'tableLabel',
  );
  @override
  late final GeneratedColumn<String> tableLabel = GeneratedColumn<String>(
    'table_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guestsMeta = const VerificationMeta('guests');
  @override
  late final GeneratedColumn<int> guests = GeneratedColumn<int>(
    'guests',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerPhoneMeta = const VerificationMeta(
    'customerPhone',
  );
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
    'customer_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryAddressMeta = const VerificationMeta(
    'deliveryAddress',
  );
  @override
  late final GeneratedColumn<String> deliveryAddress = GeneratedColumn<String>(
    'delivery_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linesJsonMeta = const VerificationMeta(
    'linesJson',
  );
  @override
  late final GeneratedColumn<String> linesJson = GeneratedColumn<String>(
    'lines_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderDiscountJsonMeta = const VerificationMeta(
    'orderDiscountJson',
  );
  @override
  late final GeneratedColumn<String> orderDiscountJson =
      GeneratedColumn<String>(
        'order_discount_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _chargesJsonMeta = const VerificationMeta(
    'chargesJson',
  );
  @override
  late final GeneratedColumn<String> chargesJson = GeneratedColumn<String>(
    'charges_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _taxLinesJsonMeta = const VerificationMeta(
    'taxLinesJson',
  );
  @override
  late final GeneratedColumn<String> taxLinesJson = GeneratedColumn<String>(
    'tax_lines_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _paymentsJsonMeta = const VerificationMeta(
    'paymentsJson',
  );
  @override
  late final GeneratedColumn<String> paymentsJson = GeneratedColumn<String>(
    'payments_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _pricesIncludeTaxMeta = const VerificationMeta(
    'pricesIncludeTax',
  );
  @override
  late final GeneratedColumn<bool> pricesIncludeTax = GeneratedColumn<bool>(
    'prices_include_tax',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("prices_include_tax" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _itemsGrossMeta = const VerificationMeta(
    'itemsGross',
  );
  @override
  late final GeneratedColumn<int> itemsGross = GeneratedColumn<int>(
    'items_gross',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountTotalMeta = const VerificationMeta(
    'discountTotal',
  );
  @override
  late final GeneratedColumn<int> discountTotal = GeneratedColumn<int>(
    'discount_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _chargesTotalMeta = const VerificationMeta(
    'chargesTotal',
  );
  @override
  late final GeneratedColumn<int> chargesTotal = GeneratedColumn<int>(
    'charges_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taxTotalMeta = const VerificationMeta(
    'taxTotal',
  );
  @override
  late final GeneratedColumn<int> taxTotal = GeneratedColumn<int>(
    'tax_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fbrFeeMeta = const VerificationMeta('fbrFee');
  @override
  late final GeneratedColumn<int> fbrFee = GeneratedColumn<int>(
    'fbr_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _roundingMeta = const VerificationMeta(
    'rounding',
  );
  @override
  late final GeneratedColumn<int> rounding = GeneratedColumn<int>(
    'rounding',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _netExTaxMeta = const VerificationMeta(
    'netExTax',
  );
  @override
  late final GeneratedColumn<int> netExTax = GeneratedColumn<int>(
    'net_ex_tax',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _refundedTotalMeta = const VerificationMeta(
    'refundedTotal',
  );
  @override
  late final GeneratedColumn<int> refundedTotal = GeneratedColumn<int>(
    'refunded_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _staffNameMeta = const VerificationMeta(
    'staffName',
  );
  @override
  late final GeneratedColumn<String> staffName = GeneratedColumn<String>(
    'staff_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceCodeMeta = const VerificationMeta(
    'deviceCode',
  );
  @override
  late final GeneratedColumn<String> deviceCode = GeneratedColumn<String>(
    'device_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kotSentMeta = const VerificationMeta(
    'kotSent',
  );
  @override
  late final GeneratedColumn<bool> kotSent = GeneratedColumn<bool>(
    'kot_sent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("kot_sent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fiscalStatusMeta = const VerificationMeta(
    'fiscalStatus',
  );
  @override
  late final GeneratedColumn<String> fiscalStatus = GeneratedColumn<String>(
    'fiscal_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _fiscalInvoiceNoMeta = const VerificationMeta(
    'fiscalInvoiceNo',
  );
  @override
  late final GeneratedColumn<String> fiscalInvoiceNo = GeneratedColumn<String>(
    'fiscal_invoice_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiscalErrorMeta = const VerificationMeta(
    'fiscalError',
  );
  @override
  late final GeneratedColumn<String> fiscalError = GeneratedColumn<String>(
    'fiscal_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiscalAtMeta = const VerificationMeta(
    'fiscalAt',
  );
  @override
  late final GeneratedColumn<int> fiscalAt = GeneratedColumn<int>(
    'fiscal_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<int> paidAt = GeneratedColumn<int>(
    'paid_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedByMeta = const VerificationMeta(
    'voidedBy',
  );
  @override
  late final GeneratedColumn<String> voidedBy = GeneratedColumn<String>(
    'voided_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    number,
    token,
    businessDate,
    orderType,
    status,
    tableId,
    tableLabel,
    guests,
    customerId,
    customerName,
    customerPhone,
    deliveryAddress,
    linesJson,
    orderDiscountJson,
    chargesJson,
    taxLinesJson,
    paymentsJson,
    pricesIncludeTax,
    itemsGross,
    discountTotal,
    chargesTotal,
    taxTotal,
    fbrFee,
    rounding,
    total,
    netExTax,
    refundedTotal,
    note,
    staffId,
    staffName,
    shiftId,
    deviceId,
    deviceCode,
    kotSent,
    fiscalStatus,
    fiscalInvoiceNo,
    fiscalError,
    fiscalAt,
    createdAt,
    paidAt,
    voidReason,
    voidedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Order> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('order_type')) {
      context.handle(
        _orderTypeMeta,
        orderType.isAcceptableOrUnknown(data['order_type']!, _orderTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_orderTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('table_id')) {
      context.handle(
        _tableIdMeta,
        tableId.isAcceptableOrUnknown(data['table_id']!, _tableIdMeta),
      );
    }
    if (data.containsKey('table_label')) {
      context.handle(
        _tableLabelMeta,
        tableLabel.isAcceptableOrUnknown(data['table_label']!, _tableLabelMeta),
      );
    }
    if (data.containsKey('guests')) {
      context.handle(
        _guestsMeta,
        guests.isAcceptableOrUnknown(data['guests']!, _guestsMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
        _customerPhoneMeta,
        customerPhone.isAcceptableOrUnknown(
          data['customer_phone']!,
          _customerPhoneMeta,
        ),
      );
    }
    if (data.containsKey('delivery_address')) {
      context.handle(
        _deliveryAddressMeta,
        deliveryAddress.isAcceptableOrUnknown(
          data['delivery_address']!,
          _deliveryAddressMeta,
        ),
      );
    }
    if (data.containsKey('lines_json')) {
      context.handle(
        _linesJsonMeta,
        linesJson.isAcceptableOrUnknown(data['lines_json']!, _linesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_linesJsonMeta);
    }
    if (data.containsKey('order_discount_json')) {
      context.handle(
        _orderDiscountJsonMeta,
        orderDiscountJson.isAcceptableOrUnknown(
          data['order_discount_json']!,
          _orderDiscountJsonMeta,
        ),
      );
    }
    if (data.containsKey('charges_json')) {
      context.handle(
        _chargesJsonMeta,
        chargesJson.isAcceptableOrUnknown(
          data['charges_json']!,
          _chargesJsonMeta,
        ),
      );
    }
    if (data.containsKey('tax_lines_json')) {
      context.handle(
        _taxLinesJsonMeta,
        taxLinesJson.isAcceptableOrUnknown(
          data['tax_lines_json']!,
          _taxLinesJsonMeta,
        ),
      );
    }
    if (data.containsKey('payments_json')) {
      context.handle(
        _paymentsJsonMeta,
        paymentsJson.isAcceptableOrUnknown(
          data['payments_json']!,
          _paymentsJsonMeta,
        ),
      );
    }
    if (data.containsKey('prices_include_tax')) {
      context.handle(
        _pricesIncludeTaxMeta,
        pricesIncludeTax.isAcceptableOrUnknown(
          data['prices_include_tax']!,
          _pricesIncludeTaxMeta,
        ),
      );
    }
    if (data.containsKey('items_gross')) {
      context.handle(
        _itemsGrossMeta,
        itemsGross.isAcceptableOrUnknown(data['items_gross']!, _itemsGrossMeta),
      );
    }
    if (data.containsKey('discount_total')) {
      context.handle(
        _discountTotalMeta,
        discountTotal.isAcceptableOrUnknown(
          data['discount_total']!,
          _discountTotalMeta,
        ),
      );
    }
    if (data.containsKey('charges_total')) {
      context.handle(
        _chargesTotalMeta,
        chargesTotal.isAcceptableOrUnknown(
          data['charges_total']!,
          _chargesTotalMeta,
        ),
      );
    }
    if (data.containsKey('tax_total')) {
      context.handle(
        _taxTotalMeta,
        taxTotal.isAcceptableOrUnknown(data['tax_total']!, _taxTotalMeta),
      );
    }
    if (data.containsKey('fbr_fee')) {
      context.handle(
        _fbrFeeMeta,
        fbrFee.isAcceptableOrUnknown(data['fbr_fee']!, _fbrFeeMeta),
      );
    }
    if (data.containsKey('rounding')) {
      context.handle(
        _roundingMeta,
        rounding.isAcceptableOrUnknown(data['rounding']!, _roundingMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('net_ex_tax')) {
      context.handle(
        _netExTaxMeta,
        netExTax.isAcceptableOrUnknown(data['net_ex_tax']!, _netExTaxMeta),
      );
    }
    if (data.containsKey('refunded_total')) {
      context.handle(
        _refundedTotalMeta,
        refundedTotal.isAcceptableOrUnknown(
          data['refunded_total']!,
          _refundedTotalMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('staff_name')) {
      context.handle(
        _staffNameMeta,
        staffName.isAcceptableOrUnknown(data['staff_name']!, _staffNameMeta),
      );
    } else if (isInserting) {
      context.missing(_staffNameMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_code')) {
      context.handle(
        _deviceCodeMeta,
        deviceCode.isAcceptableOrUnknown(data['device_code']!, _deviceCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceCodeMeta);
    }
    if (data.containsKey('kot_sent')) {
      context.handle(
        _kotSentMeta,
        kotSent.isAcceptableOrUnknown(data['kot_sent']!, _kotSentMeta),
      );
    }
    if (data.containsKey('fiscal_status')) {
      context.handle(
        _fiscalStatusMeta,
        fiscalStatus.isAcceptableOrUnknown(
          data['fiscal_status']!,
          _fiscalStatusMeta,
        ),
      );
    }
    if (data.containsKey('fiscal_invoice_no')) {
      context.handle(
        _fiscalInvoiceNoMeta,
        fiscalInvoiceNo.isAcceptableOrUnknown(
          data['fiscal_invoice_no']!,
          _fiscalInvoiceNoMeta,
        ),
      );
    }
    if (data.containsKey('fiscal_error')) {
      context.handle(
        _fiscalErrorMeta,
        fiscalError.isAcceptableOrUnknown(
          data['fiscal_error']!,
          _fiscalErrorMeta,
        ),
      );
    }
    if (data.containsKey('fiscal_at')) {
      context.handle(
        _fiscalAtMeta,
        fiscalAt.isAcceptableOrUnknown(data['fiscal_at']!, _fiscalAtMeta),
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
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    if (data.containsKey('voided_by')) {
      context.handle(
        _voidedByMeta,
        voidedBy.isAcceptableOrUnknown(data['voided_by']!, _voidedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      ),
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}token'],
      ),
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      orderType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      tableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_id'],
      ),
      tableLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_label'],
      ),
      guests: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guests'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      ),
      customerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_phone'],
      ),
      deliveryAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_address'],
      ),
      linesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lines_json'],
      )!,
      orderDiscountJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_discount_json'],
      ),
      chargesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}charges_json'],
      )!,
      taxLinesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_lines_json'],
      )!,
      paymentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payments_json'],
      )!,
      pricesIncludeTax: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}prices_include_tax'],
      )!,
      itemsGross: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}items_gross'],
      )!,
      discountTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_total'],
      )!,
      chargesTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}charges_total'],
      )!,
      taxTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_total'],
      )!,
      fbrFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fbr_fee'],
      )!,
      rounding: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounding'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      netExTax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_ex_tax'],
      )!,
      refundedTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refunded_total'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      )!,
      staffName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_name'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_code'],
      )!,
      kotSent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}kot_sent'],
      )!,
      fiscalStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiscal_status'],
      )!,
      fiscalInvoiceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiscal_invoice_no'],
      ),
      fiscalError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiscal_error'],
      ),
      fiscalAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fiscal_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_at'],
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
      voidedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voided_by'],
      ),
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class Order extends DataClass implements Insertable<Order> {
  final String id;
  final int updatedAt;
  final bool deleted;

  /// Invoice number, e.g. ESS-T1-000482. Null while held.
  final String? number;

  /// Daily order token for calling orders (#001…).
  final int? token;
  final String businessDate;

  /// 'dineIn' | 'takeaway' | 'delivery'
  final String orderType;

  /// 'held' | 'paid' | 'voided' | 'refunded' | 'partiallyRefunded'
  final String status;
  final String? tableId;
  final String? tableLabel;
  final int? guests;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final String linesJson;
  final String? orderDiscountJson;
  final String chargesJson;
  final String taxLinesJson;
  final String paymentsJson;
  final bool pricesIncludeTax;
  final int itemsGross;
  final int discountTotal;
  final int chargesTotal;
  final int taxTotal;
  final int fbrFee;
  final int rounding;
  final int total;
  final int netExTax;
  final int refundedTotal;
  final String? note;
  final String staffId;
  final String staffName;
  final String? shiftId;
  final String deviceId;
  final String deviceCode;
  final bool kotSent;

  /// 'none' | 'pending' | 'reported' | 'failed'
  final String fiscalStatus;
  final String? fiscalInvoiceNo;
  final String? fiscalError;
  final int? fiscalAt;
  final int createdAt;
  final int? paidAt;
  final String? voidReason;
  final String? voidedBy;
  const Order({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    this.number,
    this.token,
    required this.businessDate,
    required this.orderType,
    required this.status,
    this.tableId,
    this.tableLabel,
    this.guests,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    required this.linesJson,
    this.orderDiscountJson,
    required this.chargesJson,
    required this.taxLinesJson,
    required this.paymentsJson,
    required this.pricesIncludeTax,
    required this.itemsGross,
    required this.discountTotal,
    required this.chargesTotal,
    required this.taxTotal,
    required this.fbrFee,
    required this.rounding,
    required this.total,
    required this.netExTax,
    required this.refundedTotal,
    this.note,
    required this.staffId,
    required this.staffName,
    this.shiftId,
    required this.deviceId,
    required this.deviceCode,
    required this.kotSent,
    required this.fiscalStatus,
    this.fiscalInvoiceNo,
    this.fiscalError,
    this.fiscalAt,
    required this.createdAt,
    this.paidAt,
    this.voidReason,
    this.voidedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<String>(number);
    }
    if (!nullToAbsent || token != null) {
      map['token'] = Variable<int>(token);
    }
    map['business_date'] = Variable<String>(businessDate);
    map['order_type'] = Variable<String>(orderType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || tableId != null) {
      map['table_id'] = Variable<String>(tableId);
    }
    if (!nullToAbsent || tableLabel != null) {
      map['table_label'] = Variable<String>(tableLabel);
    }
    if (!nullToAbsent || guests != null) {
      map['guests'] = Variable<int>(guests);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    if (!nullToAbsent || deliveryAddress != null) {
      map['delivery_address'] = Variable<String>(deliveryAddress);
    }
    map['lines_json'] = Variable<String>(linesJson);
    if (!nullToAbsent || orderDiscountJson != null) {
      map['order_discount_json'] = Variable<String>(orderDiscountJson);
    }
    map['charges_json'] = Variable<String>(chargesJson);
    map['tax_lines_json'] = Variable<String>(taxLinesJson);
    map['payments_json'] = Variable<String>(paymentsJson);
    map['prices_include_tax'] = Variable<bool>(pricesIncludeTax);
    map['items_gross'] = Variable<int>(itemsGross);
    map['discount_total'] = Variable<int>(discountTotal);
    map['charges_total'] = Variable<int>(chargesTotal);
    map['tax_total'] = Variable<int>(taxTotal);
    map['fbr_fee'] = Variable<int>(fbrFee);
    map['rounding'] = Variable<int>(rounding);
    map['total'] = Variable<int>(total);
    map['net_ex_tax'] = Variable<int>(netExTax);
    map['refunded_total'] = Variable<int>(refundedTotal);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['staff_id'] = Variable<String>(staffId);
    map['staff_name'] = Variable<String>(staffName);
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<String>(shiftId);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['device_code'] = Variable<String>(deviceCode);
    map['kot_sent'] = Variable<bool>(kotSent);
    map['fiscal_status'] = Variable<String>(fiscalStatus);
    if (!nullToAbsent || fiscalInvoiceNo != null) {
      map['fiscal_invoice_no'] = Variable<String>(fiscalInvoiceNo);
    }
    if (!nullToAbsent || fiscalError != null) {
      map['fiscal_error'] = Variable<String>(fiscalError);
    }
    if (!nullToAbsent || fiscalAt != null) {
      map['fiscal_at'] = Variable<int>(fiscalAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || paidAt != null) {
      map['paid_at'] = Variable<int>(paidAt);
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    if (!nullToAbsent || voidedBy != null) {
      map['voided_by'] = Variable<String>(voidedBy);
    }
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      token: token == null && nullToAbsent
          ? const Value.absent()
          : Value(token),
      businessDate: Value(businessDate),
      orderType: Value(orderType),
      status: Value(status),
      tableId: tableId == null && nullToAbsent
          ? const Value.absent()
          : Value(tableId),
      tableLabel: tableLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(tableLabel),
      guests: guests == null && nullToAbsent
          ? const Value.absent()
          : Value(guests),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      deliveryAddress: deliveryAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryAddress),
      linesJson: Value(linesJson),
      orderDiscountJson: orderDiscountJson == null && nullToAbsent
          ? const Value.absent()
          : Value(orderDiscountJson),
      chargesJson: Value(chargesJson),
      taxLinesJson: Value(taxLinesJson),
      paymentsJson: Value(paymentsJson),
      pricesIncludeTax: Value(pricesIncludeTax),
      itemsGross: Value(itemsGross),
      discountTotal: Value(discountTotal),
      chargesTotal: Value(chargesTotal),
      taxTotal: Value(taxTotal),
      fbrFee: Value(fbrFee),
      rounding: Value(rounding),
      total: Value(total),
      netExTax: Value(netExTax),
      refundedTotal: Value(refundedTotal),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      staffId: Value(staffId),
      staffName: Value(staffName),
      shiftId: shiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftId),
      deviceId: Value(deviceId),
      deviceCode: Value(deviceCode),
      kotSent: Value(kotSent),
      fiscalStatus: Value(fiscalStatus),
      fiscalInvoiceNo: fiscalInvoiceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(fiscalInvoiceNo),
      fiscalError: fiscalError == null && nullToAbsent
          ? const Value.absent()
          : Value(fiscalError),
      fiscalAt: fiscalAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fiscalAt),
      createdAt: Value(createdAt),
      paidAt: paidAt == null && nullToAbsent
          ? const Value.absent()
          : Value(paidAt),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
      voidedBy: voidedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedBy),
    );
  }

  factory Order.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      number: serializer.fromJson<String?>(json['number']),
      token: serializer.fromJson<int?>(json['token']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      orderType: serializer.fromJson<String>(json['orderType']),
      status: serializer.fromJson<String>(json['status']),
      tableId: serializer.fromJson<String?>(json['tableId']),
      tableLabel: serializer.fromJson<String?>(json['tableLabel']),
      guests: serializer.fromJson<int?>(json['guests']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      deliveryAddress: serializer.fromJson<String?>(json['deliveryAddress']),
      linesJson: serializer.fromJson<String>(json['linesJson']),
      orderDiscountJson: serializer.fromJson<String?>(
        json['orderDiscountJson'],
      ),
      chargesJson: serializer.fromJson<String>(json['chargesJson']),
      taxLinesJson: serializer.fromJson<String>(json['taxLinesJson']),
      paymentsJson: serializer.fromJson<String>(json['paymentsJson']),
      pricesIncludeTax: serializer.fromJson<bool>(json['pricesIncludeTax']),
      itemsGross: serializer.fromJson<int>(json['itemsGross']),
      discountTotal: serializer.fromJson<int>(json['discountTotal']),
      chargesTotal: serializer.fromJson<int>(json['chargesTotal']),
      taxTotal: serializer.fromJson<int>(json['taxTotal']),
      fbrFee: serializer.fromJson<int>(json['fbrFee']),
      rounding: serializer.fromJson<int>(json['rounding']),
      total: serializer.fromJson<int>(json['total']),
      netExTax: serializer.fromJson<int>(json['netExTax']),
      refundedTotal: serializer.fromJson<int>(json['refundedTotal']),
      note: serializer.fromJson<String?>(json['note']),
      staffId: serializer.fromJson<String>(json['staffId']),
      staffName: serializer.fromJson<String>(json['staffName']),
      shiftId: serializer.fromJson<String?>(json['shiftId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceCode: serializer.fromJson<String>(json['deviceCode']),
      kotSent: serializer.fromJson<bool>(json['kotSent']),
      fiscalStatus: serializer.fromJson<String>(json['fiscalStatus']),
      fiscalInvoiceNo: serializer.fromJson<String?>(json['fiscalInvoiceNo']),
      fiscalError: serializer.fromJson<String?>(json['fiscalError']),
      fiscalAt: serializer.fromJson<int?>(json['fiscalAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      paidAt: serializer.fromJson<int?>(json['paidAt']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
      voidedBy: serializer.fromJson<String?>(json['voidedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'number': serializer.toJson<String?>(number),
      'token': serializer.toJson<int?>(token),
      'businessDate': serializer.toJson<String>(businessDate),
      'orderType': serializer.toJson<String>(orderType),
      'status': serializer.toJson<String>(status),
      'tableId': serializer.toJson<String?>(tableId),
      'tableLabel': serializer.toJson<String?>(tableLabel),
      'guests': serializer.toJson<int?>(guests),
      'customerId': serializer.toJson<String?>(customerId),
      'customerName': serializer.toJson<String?>(customerName),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'deliveryAddress': serializer.toJson<String?>(deliveryAddress),
      'linesJson': serializer.toJson<String>(linesJson),
      'orderDiscountJson': serializer.toJson<String?>(orderDiscountJson),
      'chargesJson': serializer.toJson<String>(chargesJson),
      'taxLinesJson': serializer.toJson<String>(taxLinesJson),
      'paymentsJson': serializer.toJson<String>(paymentsJson),
      'pricesIncludeTax': serializer.toJson<bool>(pricesIncludeTax),
      'itemsGross': serializer.toJson<int>(itemsGross),
      'discountTotal': serializer.toJson<int>(discountTotal),
      'chargesTotal': serializer.toJson<int>(chargesTotal),
      'taxTotal': serializer.toJson<int>(taxTotal),
      'fbrFee': serializer.toJson<int>(fbrFee),
      'rounding': serializer.toJson<int>(rounding),
      'total': serializer.toJson<int>(total),
      'netExTax': serializer.toJson<int>(netExTax),
      'refundedTotal': serializer.toJson<int>(refundedTotal),
      'note': serializer.toJson<String?>(note),
      'staffId': serializer.toJson<String>(staffId),
      'staffName': serializer.toJson<String>(staffName),
      'shiftId': serializer.toJson<String?>(shiftId),
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceCode': serializer.toJson<String>(deviceCode),
      'kotSent': serializer.toJson<bool>(kotSent),
      'fiscalStatus': serializer.toJson<String>(fiscalStatus),
      'fiscalInvoiceNo': serializer.toJson<String?>(fiscalInvoiceNo),
      'fiscalError': serializer.toJson<String?>(fiscalError),
      'fiscalAt': serializer.toJson<int?>(fiscalAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'paidAt': serializer.toJson<int?>(paidAt),
      'voidReason': serializer.toJson<String?>(voidReason),
      'voidedBy': serializer.toJson<String?>(voidedBy),
    };
  }

  Order copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    Value<String?> number = const Value.absent(),
    Value<int?> token = const Value.absent(),
    String? businessDate,
    String? orderType,
    String? status,
    Value<String?> tableId = const Value.absent(),
    Value<String?> tableLabel = const Value.absent(),
    Value<int?> guests = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    Value<String?> customerName = const Value.absent(),
    Value<String?> customerPhone = const Value.absent(),
    Value<String?> deliveryAddress = const Value.absent(),
    String? linesJson,
    Value<String?> orderDiscountJson = const Value.absent(),
    String? chargesJson,
    String? taxLinesJson,
    String? paymentsJson,
    bool? pricesIncludeTax,
    int? itemsGross,
    int? discountTotal,
    int? chargesTotal,
    int? taxTotal,
    int? fbrFee,
    int? rounding,
    int? total,
    int? netExTax,
    int? refundedTotal,
    Value<String?> note = const Value.absent(),
    String? staffId,
    String? staffName,
    Value<String?> shiftId = const Value.absent(),
    String? deviceId,
    String? deviceCode,
    bool? kotSent,
    String? fiscalStatus,
    Value<String?> fiscalInvoiceNo = const Value.absent(),
    Value<String?> fiscalError = const Value.absent(),
    Value<int?> fiscalAt = const Value.absent(),
    int? createdAt,
    Value<int?> paidAt = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
    Value<String?> voidedBy = const Value.absent(),
  }) => Order(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    number: number.present ? number.value : this.number,
    token: token.present ? token.value : this.token,
    businessDate: businessDate ?? this.businessDate,
    orderType: orderType ?? this.orderType,
    status: status ?? this.status,
    tableId: tableId.present ? tableId.value : this.tableId,
    tableLabel: tableLabel.present ? tableLabel.value : this.tableLabel,
    guests: guests.present ? guests.value : this.guests,
    customerId: customerId.present ? customerId.value : this.customerId,
    customerName: customerName.present ? customerName.value : this.customerName,
    customerPhone: customerPhone.present
        ? customerPhone.value
        : this.customerPhone,
    deliveryAddress: deliveryAddress.present
        ? deliveryAddress.value
        : this.deliveryAddress,
    linesJson: linesJson ?? this.linesJson,
    orderDiscountJson: orderDiscountJson.present
        ? orderDiscountJson.value
        : this.orderDiscountJson,
    chargesJson: chargesJson ?? this.chargesJson,
    taxLinesJson: taxLinesJson ?? this.taxLinesJson,
    paymentsJson: paymentsJson ?? this.paymentsJson,
    pricesIncludeTax: pricesIncludeTax ?? this.pricesIncludeTax,
    itemsGross: itemsGross ?? this.itemsGross,
    discountTotal: discountTotal ?? this.discountTotal,
    chargesTotal: chargesTotal ?? this.chargesTotal,
    taxTotal: taxTotal ?? this.taxTotal,
    fbrFee: fbrFee ?? this.fbrFee,
    rounding: rounding ?? this.rounding,
    total: total ?? this.total,
    netExTax: netExTax ?? this.netExTax,
    refundedTotal: refundedTotal ?? this.refundedTotal,
    note: note.present ? note.value : this.note,
    staffId: staffId ?? this.staffId,
    staffName: staffName ?? this.staffName,
    shiftId: shiftId.present ? shiftId.value : this.shiftId,
    deviceId: deviceId ?? this.deviceId,
    deviceCode: deviceCode ?? this.deviceCode,
    kotSent: kotSent ?? this.kotSent,
    fiscalStatus: fiscalStatus ?? this.fiscalStatus,
    fiscalInvoiceNo: fiscalInvoiceNo.present
        ? fiscalInvoiceNo.value
        : this.fiscalInvoiceNo,
    fiscalError: fiscalError.present ? fiscalError.value : this.fiscalError,
    fiscalAt: fiscalAt.present ? fiscalAt.value : this.fiscalAt,
    createdAt: createdAt ?? this.createdAt,
    paidAt: paidAt.present ? paidAt.value : this.paidAt,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
    voidedBy: voidedBy.present ? voidedBy.value : this.voidedBy,
  );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      number: data.number.present ? data.number.value : this.number,
      token: data.token.present ? data.token.value : this.token,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      orderType: data.orderType.present ? data.orderType.value : this.orderType,
      status: data.status.present ? data.status.value : this.status,
      tableId: data.tableId.present ? data.tableId.value : this.tableId,
      tableLabel: data.tableLabel.present
          ? data.tableLabel.value
          : this.tableLabel,
      guests: data.guests.present ? data.guests.value : this.guests,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      deliveryAddress: data.deliveryAddress.present
          ? data.deliveryAddress.value
          : this.deliveryAddress,
      linesJson: data.linesJson.present ? data.linesJson.value : this.linesJson,
      orderDiscountJson: data.orderDiscountJson.present
          ? data.orderDiscountJson.value
          : this.orderDiscountJson,
      chargesJson: data.chargesJson.present
          ? data.chargesJson.value
          : this.chargesJson,
      taxLinesJson: data.taxLinesJson.present
          ? data.taxLinesJson.value
          : this.taxLinesJson,
      paymentsJson: data.paymentsJson.present
          ? data.paymentsJson.value
          : this.paymentsJson,
      pricesIncludeTax: data.pricesIncludeTax.present
          ? data.pricesIncludeTax.value
          : this.pricesIncludeTax,
      itemsGross: data.itemsGross.present
          ? data.itemsGross.value
          : this.itemsGross,
      discountTotal: data.discountTotal.present
          ? data.discountTotal.value
          : this.discountTotal,
      chargesTotal: data.chargesTotal.present
          ? data.chargesTotal.value
          : this.chargesTotal,
      taxTotal: data.taxTotal.present ? data.taxTotal.value : this.taxTotal,
      fbrFee: data.fbrFee.present ? data.fbrFee.value : this.fbrFee,
      rounding: data.rounding.present ? data.rounding.value : this.rounding,
      total: data.total.present ? data.total.value : this.total,
      netExTax: data.netExTax.present ? data.netExTax.value : this.netExTax,
      refundedTotal: data.refundedTotal.present
          ? data.refundedTotal.value
          : this.refundedTotal,
      note: data.note.present ? data.note.value : this.note,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      staffName: data.staffName.present ? data.staffName.value : this.staffName,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceCode: data.deviceCode.present
          ? data.deviceCode.value
          : this.deviceCode,
      kotSent: data.kotSent.present ? data.kotSent.value : this.kotSent,
      fiscalStatus: data.fiscalStatus.present
          ? data.fiscalStatus.value
          : this.fiscalStatus,
      fiscalInvoiceNo: data.fiscalInvoiceNo.present
          ? data.fiscalInvoiceNo.value
          : this.fiscalInvoiceNo,
      fiscalError: data.fiscalError.present
          ? data.fiscalError.value
          : this.fiscalError,
      fiscalAt: data.fiscalAt.present ? data.fiscalAt.value : this.fiscalAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
      voidedBy: data.voidedBy.present ? data.voidedBy.value : this.voidedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('number: $number, ')
          ..write('token: $token, ')
          ..write('businessDate: $businessDate, ')
          ..write('orderType: $orderType, ')
          ..write('status: $status, ')
          ..write('tableId: $tableId, ')
          ..write('tableLabel: $tableLabel, ')
          ..write('guests: $guests, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('deliveryAddress: $deliveryAddress, ')
          ..write('linesJson: $linesJson, ')
          ..write('orderDiscountJson: $orderDiscountJson, ')
          ..write('chargesJson: $chargesJson, ')
          ..write('taxLinesJson: $taxLinesJson, ')
          ..write('paymentsJson: $paymentsJson, ')
          ..write('pricesIncludeTax: $pricesIncludeTax, ')
          ..write('itemsGross: $itemsGross, ')
          ..write('discountTotal: $discountTotal, ')
          ..write('chargesTotal: $chargesTotal, ')
          ..write('taxTotal: $taxTotal, ')
          ..write('fbrFee: $fbrFee, ')
          ..write('rounding: $rounding, ')
          ..write('total: $total, ')
          ..write('netExTax: $netExTax, ')
          ..write('refundedTotal: $refundedTotal, ')
          ..write('note: $note, ')
          ..write('staffId: $staffId, ')
          ..write('staffName: $staffName, ')
          ..write('shiftId: $shiftId, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceCode: $deviceCode, ')
          ..write('kotSent: $kotSent, ')
          ..write('fiscalStatus: $fiscalStatus, ')
          ..write('fiscalInvoiceNo: $fiscalInvoiceNo, ')
          ..write('fiscalError: $fiscalError, ')
          ..write('fiscalAt: $fiscalAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('paidAt: $paidAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('voidedBy: $voidedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    updatedAt,
    deleted,
    number,
    token,
    businessDate,
    orderType,
    status,
    tableId,
    tableLabel,
    guests,
    customerId,
    customerName,
    customerPhone,
    deliveryAddress,
    linesJson,
    orderDiscountJson,
    chargesJson,
    taxLinesJson,
    paymentsJson,
    pricesIncludeTax,
    itemsGross,
    discountTotal,
    chargesTotal,
    taxTotal,
    fbrFee,
    rounding,
    total,
    netExTax,
    refundedTotal,
    note,
    staffId,
    staffName,
    shiftId,
    deviceId,
    deviceCode,
    kotSent,
    fiscalStatus,
    fiscalInvoiceNo,
    fiscalError,
    fiscalAt,
    createdAt,
    paidAt,
    voidReason,
    voidedBy,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.number == this.number &&
          other.token == this.token &&
          other.businessDate == this.businessDate &&
          other.orderType == this.orderType &&
          other.status == this.status &&
          other.tableId == this.tableId &&
          other.tableLabel == this.tableLabel &&
          other.guests == this.guests &&
          other.customerId == this.customerId &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.deliveryAddress == this.deliveryAddress &&
          other.linesJson == this.linesJson &&
          other.orderDiscountJson == this.orderDiscountJson &&
          other.chargesJson == this.chargesJson &&
          other.taxLinesJson == this.taxLinesJson &&
          other.paymentsJson == this.paymentsJson &&
          other.pricesIncludeTax == this.pricesIncludeTax &&
          other.itemsGross == this.itemsGross &&
          other.discountTotal == this.discountTotal &&
          other.chargesTotal == this.chargesTotal &&
          other.taxTotal == this.taxTotal &&
          other.fbrFee == this.fbrFee &&
          other.rounding == this.rounding &&
          other.total == this.total &&
          other.netExTax == this.netExTax &&
          other.refundedTotal == this.refundedTotal &&
          other.note == this.note &&
          other.staffId == this.staffId &&
          other.staffName == this.staffName &&
          other.shiftId == this.shiftId &&
          other.deviceId == this.deviceId &&
          other.deviceCode == this.deviceCode &&
          other.kotSent == this.kotSent &&
          other.fiscalStatus == this.fiscalStatus &&
          other.fiscalInvoiceNo == this.fiscalInvoiceNo &&
          other.fiscalError == this.fiscalError &&
          other.fiscalAt == this.fiscalAt &&
          other.createdAt == this.createdAt &&
          other.paidAt == this.paidAt &&
          other.voidReason == this.voidReason &&
          other.voidedBy == this.voidedBy);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String?> number;
  final Value<int?> token;
  final Value<String> businessDate;
  final Value<String> orderType;
  final Value<String> status;
  final Value<String?> tableId;
  final Value<String?> tableLabel;
  final Value<int?> guests;
  final Value<String?> customerId;
  final Value<String?> customerName;
  final Value<String?> customerPhone;
  final Value<String?> deliveryAddress;
  final Value<String> linesJson;
  final Value<String?> orderDiscountJson;
  final Value<String> chargesJson;
  final Value<String> taxLinesJson;
  final Value<String> paymentsJson;
  final Value<bool> pricesIncludeTax;
  final Value<int> itemsGross;
  final Value<int> discountTotal;
  final Value<int> chargesTotal;
  final Value<int> taxTotal;
  final Value<int> fbrFee;
  final Value<int> rounding;
  final Value<int> total;
  final Value<int> netExTax;
  final Value<int> refundedTotal;
  final Value<String?> note;
  final Value<String> staffId;
  final Value<String> staffName;
  final Value<String?> shiftId;
  final Value<String> deviceId;
  final Value<String> deviceCode;
  final Value<bool> kotSent;
  final Value<String> fiscalStatus;
  final Value<String?> fiscalInvoiceNo;
  final Value<String?> fiscalError;
  final Value<int?> fiscalAt;
  final Value<int> createdAt;
  final Value<int?> paidAt;
  final Value<String?> voidReason;
  final Value<String?> voidedBy;
  final Value<int> rowid;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.number = const Value.absent(),
    this.token = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.orderType = const Value.absent(),
    this.status = const Value.absent(),
    this.tableId = const Value.absent(),
    this.tableLabel = const Value.absent(),
    this.guests = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.deliveryAddress = const Value.absent(),
    this.linesJson = const Value.absent(),
    this.orderDiscountJson = const Value.absent(),
    this.chargesJson = const Value.absent(),
    this.taxLinesJson = const Value.absent(),
    this.paymentsJson = const Value.absent(),
    this.pricesIncludeTax = const Value.absent(),
    this.itemsGross = const Value.absent(),
    this.discountTotal = const Value.absent(),
    this.chargesTotal = const Value.absent(),
    this.taxTotal = const Value.absent(),
    this.fbrFee = const Value.absent(),
    this.rounding = const Value.absent(),
    this.total = const Value.absent(),
    this.netExTax = const Value.absent(),
    this.refundedTotal = const Value.absent(),
    this.note = const Value.absent(),
    this.staffId = const Value.absent(),
    this.staffName = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceCode = const Value.absent(),
    this.kotSent = const Value.absent(),
    this.fiscalStatus = const Value.absent(),
    this.fiscalInvoiceNo = const Value.absent(),
    this.fiscalError = const Value.absent(),
    this.fiscalAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.voidedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    this.number = const Value.absent(),
    this.token = const Value.absent(),
    required String businessDate,
    required String orderType,
    required String status,
    this.tableId = const Value.absent(),
    this.tableLabel = const Value.absent(),
    this.guests = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.deliveryAddress = const Value.absent(),
    required String linesJson,
    this.orderDiscountJson = const Value.absent(),
    this.chargesJson = const Value.absent(),
    this.taxLinesJson = const Value.absent(),
    this.paymentsJson = const Value.absent(),
    this.pricesIncludeTax = const Value.absent(),
    this.itemsGross = const Value.absent(),
    this.discountTotal = const Value.absent(),
    this.chargesTotal = const Value.absent(),
    this.taxTotal = const Value.absent(),
    this.fbrFee = const Value.absent(),
    this.rounding = const Value.absent(),
    this.total = const Value.absent(),
    this.netExTax = const Value.absent(),
    this.refundedTotal = const Value.absent(),
    this.note = const Value.absent(),
    required String staffId,
    required String staffName,
    this.shiftId = const Value.absent(),
    required String deviceId,
    required String deviceCode,
    this.kotSent = const Value.absent(),
    this.fiscalStatus = const Value.absent(),
    this.fiscalInvoiceNo = const Value.absent(),
    this.fiscalError = const Value.absent(),
    this.fiscalAt = const Value.absent(),
    required int createdAt,
    this.paidAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.voidedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       businessDate = Value(businessDate),
       orderType = Value(orderType),
       status = Value(status),
       linesJson = Value(linesJson),
       staffId = Value(staffId),
       staffName = Value(staffName),
       deviceId = Value(deviceId),
       deviceCode = Value(deviceCode),
       createdAt = Value(createdAt);
  static Insertable<Order> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? number,
    Expression<int>? token,
    Expression<String>? businessDate,
    Expression<String>? orderType,
    Expression<String>? status,
    Expression<String>? tableId,
    Expression<String>? tableLabel,
    Expression<int>? guests,
    Expression<String>? customerId,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<String>? deliveryAddress,
    Expression<String>? linesJson,
    Expression<String>? orderDiscountJson,
    Expression<String>? chargesJson,
    Expression<String>? taxLinesJson,
    Expression<String>? paymentsJson,
    Expression<bool>? pricesIncludeTax,
    Expression<int>? itemsGross,
    Expression<int>? discountTotal,
    Expression<int>? chargesTotal,
    Expression<int>? taxTotal,
    Expression<int>? fbrFee,
    Expression<int>? rounding,
    Expression<int>? total,
    Expression<int>? netExTax,
    Expression<int>? refundedTotal,
    Expression<String>? note,
    Expression<String>? staffId,
    Expression<String>? staffName,
    Expression<String>? shiftId,
    Expression<String>? deviceId,
    Expression<String>? deviceCode,
    Expression<bool>? kotSent,
    Expression<String>? fiscalStatus,
    Expression<String>? fiscalInvoiceNo,
    Expression<String>? fiscalError,
    Expression<int>? fiscalAt,
    Expression<int>? createdAt,
    Expression<int>? paidAt,
    Expression<String>? voidReason,
    Expression<String>? voidedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (number != null) 'number': number,
      if (token != null) 'token': token,
      if (businessDate != null) 'business_date': businessDate,
      if (orderType != null) 'order_type': orderType,
      if (status != null) 'status': status,
      if (tableId != null) 'table_id': tableId,
      if (tableLabel != null) 'table_label': tableLabel,
      if (guests != null) 'guests': guests,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (linesJson != null) 'lines_json': linesJson,
      if (orderDiscountJson != null) 'order_discount_json': orderDiscountJson,
      if (chargesJson != null) 'charges_json': chargesJson,
      if (taxLinesJson != null) 'tax_lines_json': taxLinesJson,
      if (paymentsJson != null) 'payments_json': paymentsJson,
      if (pricesIncludeTax != null) 'prices_include_tax': pricesIncludeTax,
      if (itemsGross != null) 'items_gross': itemsGross,
      if (discountTotal != null) 'discount_total': discountTotal,
      if (chargesTotal != null) 'charges_total': chargesTotal,
      if (taxTotal != null) 'tax_total': taxTotal,
      if (fbrFee != null) 'fbr_fee': fbrFee,
      if (rounding != null) 'rounding': rounding,
      if (total != null) 'total': total,
      if (netExTax != null) 'net_ex_tax': netExTax,
      if (refundedTotal != null) 'refunded_total': refundedTotal,
      if (note != null) 'note': note,
      if (staffId != null) 'staff_id': staffId,
      if (staffName != null) 'staff_name': staffName,
      if (shiftId != null) 'shift_id': shiftId,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceCode != null) 'device_code': deviceCode,
      if (kotSent != null) 'kot_sent': kotSent,
      if (fiscalStatus != null) 'fiscal_status': fiscalStatus,
      if (fiscalInvoiceNo != null) 'fiscal_invoice_no': fiscalInvoiceNo,
      if (fiscalError != null) 'fiscal_error': fiscalError,
      if (fiscalAt != null) 'fiscal_at': fiscalAt,
      if (createdAt != null) 'created_at': createdAt,
      if (paidAt != null) 'paid_at': paidAt,
      if (voidReason != null) 'void_reason': voidReason,
      if (voidedBy != null) 'voided_by': voidedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String?>? number,
    Value<int?>? token,
    Value<String>? businessDate,
    Value<String>? orderType,
    Value<String>? status,
    Value<String?>? tableId,
    Value<String?>? tableLabel,
    Value<int?>? guests,
    Value<String?>? customerId,
    Value<String?>? customerName,
    Value<String?>? customerPhone,
    Value<String?>? deliveryAddress,
    Value<String>? linesJson,
    Value<String?>? orderDiscountJson,
    Value<String>? chargesJson,
    Value<String>? taxLinesJson,
    Value<String>? paymentsJson,
    Value<bool>? pricesIncludeTax,
    Value<int>? itemsGross,
    Value<int>? discountTotal,
    Value<int>? chargesTotal,
    Value<int>? taxTotal,
    Value<int>? fbrFee,
    Value<int>? rounding,
    Value<int>? total,
    Value<int>? netExTax,
    Value<int>? refundedTotal,
    Value<String?>? note,
    Value<String>? staffId,
    Value<String>? staffName,
    Value<String?>? shiftId,
    Value<String>? deviceId,
    Value<String>? deviceCode,
    Value<bool>? kotSent,
    Value<String>? fiscalStatus,
    Value<String?>? fiscalInvoiceNo,
    Value<String?>? fiscalError,
    Value<int?>? fiscalAt,
    Value<int>? createdAt,
    Value<int?>? paidAt,
    Value<String?>? voidReason,
    Value<String?>? voidedBy,
    Value<int>? rowid,
  }) {
    return OrdersCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      number: number ?? this.number,
      token: token ?? this.token,
      businessDate: businessDate ?? this.businessDate,
      orderType: orderType ?? this.orderType,
      status: status ?? this.status,
      tableId: tableId ?? this.tableId,
      tableLabel: tableLabel ?? this.tableLabel,
      guests: guests ?? this.guests,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      linesJson: linesJson ?? this.linesJson,
      orderDiscountJson: orderDiscountJson ?? this.orderDiscountJson,
      chargesJson: chargesJson ?? this.chargesJson,
      taxLinesJson: taxLinesJson ?? this.taxLinesJson,
      paymentsJson: paymentsJson ?? this.paymentsJson,
      pricesIncludeTax: pricesIncludeTax ?? this.pricesIncludeTax,
      itemsGross: itemsGross ?? this.itemsGross,
      discountTotal: discountTotal ?? this.discountTotal,
      chargesTotal: chargesTotal ?? this.chargesTotal,
      taxTotal: taxTotal ?? this.taxTotal,
      fbrFee: fbrFee ?? this.fbrFee,
      rounding: rounding ?? this.rounding,
      total: total ?? this.total,
      netExTax: netExTax ?? this.netExTax,
      refundedTotal: refundedTotal ?? this.refundedTotal,
      note: note ?? this.note,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      shiftId: shiftId ?? this.shiftId,
      deviceId: deviceId ?? this.deviceId,
      deviceCode: deviceCode ?? this.deviceCode,
      kotSent: kotSent ?? this.kotSent,
      fiscalStatus: fiscalStatus ?? this.fiscalStatus,
      fiscalInvoiceNo: fiscalInvoiceNo ?? this.fiscalInvoiceNo,
      fiscalError: fiscalError ?? this.fiscalError,
      fiscalAt: fiscalAt ?? this.fiscalAt,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      voidReason: voidReason ?? this.voidReason,
      voidedBy: voidedBy ?? this.voidedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (token.present) {
      map['token'] = Variable<int>(token.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (orderType.present) {
      map['order_type'] = Variable<String>(orderType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (tableId.present) {
      map['table_id'] = Variable<String>(tableId.value);
    }
    if (tableLabel.present) {
      map['table_label'] = Variable<String>(tableLabel.value);
    }
    if (guests.present) {
      map['guests'] = Variable<int>(guests.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (deliveryAddress.present) {
      map['delivery_address'] = Variable<String>(deliveryAddress.value);
    }
    if (linesJson.present) {
      map['lines_json'] = Variable<String>(linesJson.value);
    }
    if (orderDiscountJson.present) {
      map['order_discount_json'] = Variable<String>(orderDiscountJson.value);
    }
    if (chargesJson.present) {
      map['charges_json'] = Variable<String>(chargesJson.value);
    }
    if (taxLinesJson.present) {
      map['tax_lines_json'] = Variable<String>(taxLinesJson.value);
    }
    if (paymentsJson.present) {
      map['payments_json'] = Variable<String>(paymentsJson.value);
    }
    if (pricesIncludeTax.present) {
      map['prices_include_tax'] = Variable<bool>(pricesIncludeTax.value);
    }
    if (itemsGross.present) {
      map['items_gross'] = Variable<int>(itemsGross.value);
    }
    if (discountTotal.present) {
      map['discount_total'] = Variable<int>(discountTotal.value);
    }
    if (chargesTotal.present) {
      map['charges_total'] = Variable<int>(chargesTotal.value);
    }
    if (taxTotal.present) {
      map['tax_total'] = Variable<int>(taxTotal.value);
    }
    if (fbrFee.present) {
      map['fbr_fee'] = Variable<int>(fbrFee.value);
    }
    if (rounding.present) {
      map['rounding'] = Variable<int>(rounding.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (netExTax.present) {
      map['net_ex_tax'] = Variable<int>(netExTax.value);
    }
    if (refundedTotal.present) {
      map['refunded_total'] = Variable<int>(refundedTotal.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (staffName.present) {
      map['staff_name'] = Variable<String>(staffName.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceCode.present) {
      map['device_code'] = Variable<String>(deviceCode.value);
    }
    if (kotSent.present) {
      map['kot_sent'] = Variable<bool>(kotSent.value);
    }
    if (fiscalStatus.present) {
      map['fiscal_status'] = Variable<String>(fiscalStatus.value);
    }
    if (fiscalInvoiceNo.present) {
      map['fiscal_invoice_no'] = Variable<String>(fiscalInvoiceNo.value);
    }
    if (fiscalError.present) {
      map['fiscal_error'] = Variable<String>(fiscalError.value);
    }
    if (fiscalAt.present) {
      map['fiscal_at'] = Variable<int>(fiscalAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<int>(paidAt.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (voidedBy.present) {
      map['voided_by'] = Variable<String>(voidedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('number: $number, ')
          ..write('token: $token, ')
          ..write('businessDate: $businessDate, ')
          ..write('orderType: $orderType, ')
          ..write('status: $status, ')
          ..write('tableId: $tableId, ')
          ..write('tableLabel: $tableLabel, ')
          ..write('guests: $guests, ')
          ..write('customerId: $customerId, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('deliveryAddress: $deliveryAddress, ')
          ..write('linesJson: $linesJson, ')
          ..write('orderDiscountJson: $orderDiscountJson, ')
          ..write('chargesJson: $chargesJson, ')
          ..write('taxLinesJson: $taxLinesJson, ')
          ..write('paymentsJson: $paymentsJson, ')
          ..write('pricesIncludeTax: $pricesIncludeTax, ')
          ..write('itemsGross: $itemsGross, ')
          ..write('discountTotal: $discountTotal, ')
          ..write('chargesTotal: $chargesTotal, ')
          ..write('taxTotal: $taxTotal, ')
          ..write('fbrFee: $fbrFee, ')
          ..write('rounding: $rounding, ')
          ..write('total: $total, ')
          ..write('netExTax: $netExTax, ')
          ..write('refundedTotal: $refundedTotal, ')
          ..write('note: $note, ')
          ..write('staffId: $staffId, ')
          ..write('staffName: $staffName, ')
          ..write('shiftId: $shiftId, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceCode: $deviceCode, ')
          ..write('kotSent: $kotSent, ')
          ..write('fiscalStatus: $fiscalStatus, ')
          ..write('fiscalInvoiceNo: $fiscalInvoiceNo, ')
          ..write('fiscalError: $fiscalError, ')
          ..write('fiscalAt: $fiscalAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('paidAt: $paidAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('voidedBy: $voidedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefundsTable extends Refunds with TableInfo<$RefundsTable, Refund> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderNumberMeta = const VerificationMeta(
    'orderNumber',
  );
  @override
  late final GeneratedColumn<String> orderNumber = GeneratedColumn<String>(
    'order_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linesJsonMeta = const VerificationMeta(
    'linesJson',
  );
  @override
  late final GeneratedColumn<String> linesJson = GeneratedColumn<String>(
    'lines_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<int> taxAmount = GeneratedColumn<int>(
    'tax_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodIdMeta = const VerificationMeta(
    'methodId',
  );
  @override
  late final GeneratedColumn<String> methodId = GeneratedColumn<String>(
    'method_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodNameMeta = const VerificationMeta(
    'methodName',
  );
  @override
  late final GeneratedColumn<String> methodName = GeneratedColumn<String>(
    'method_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateGroupMeta = const VerificationMeta(
    'rateGroup',
  );
  @override
  late final GeneratedColumn<String> rateGroup = GeneratedColumn<String>(
    'rate_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restockMeta = const VerificationMeta(
    'restock',
  );
  @override
  late final GeneratedColumn<bool> restock = GeneratedColumn<bool>(
    'restock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("restock" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _staffNameMeta = const VerificationMeta(
    'staffName',
  );
  @override
  late final GeneratedColumn<String> staffName = GeneratedColumn<String>(
    'staff_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _approvedByMeta = const VerificationMeta(
    'approvedBy',
  );
  @override
  late final GeneratedColumn<String> approvedBy = GeneratedColumn<String>(
    'approved_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    orderId,
    orderNumber,
    linesJson,
    amount,
    taxAmount,
    methodId,
    methodName,
    rateGroup,
    reason,
    restock,
    staffId,
    staffName,
    approvedBy,
    shiftId,
    deviceId,
    businessDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'refunds';
  @override
  VerificationContext validateIntegrity(
    Insertable<Refund> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('order_number')) {
      context.handle(
        _orderNumberMeta,
        orderNumber.isAcceptableOrUnknown(
          data['order_number']!,
          _orderNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orderNumberMeta);
    }
    if (data.containsKey('lines_json')) {
      context.handle(
        _linesJsonMeta,
        linesJson.isAcceptableOrUnknown(data['lines_json']!, _linesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_linesJsonMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_taxAmountMeta);
    }
    if (data.containsKey('method_id')) {
      context.handle(
        _methodIdMeta,
        methodId.isAcceptableOrUnknown(data['method_id']!, _methodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_methodIdMeta);
    }
    if (data.containsKey('method_name')) {
      context.handle(
        _methodNameMeta,
        methodName.isAcceptableOrUnknown(data['method_name']!, _methodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_methodNameMeta);
    }
    if (data.containsKey('rate_group')) {
      context.handle(
        _rateGroupMeta,
        rateGroup.isAcceptableOrUnknown(data['rate_group']!, _rateGroupMeta),
      );
    } else if (isInserting) {
      context.missing(_rateGroupMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('restock')) {
      context.handle(
        _restockMeta,
        restock.isAcceptableOrUnknown(data['restock']!, _restockMeta),
      );
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('staff_name')) {
      context.handle(
        _staffNameMeta,
        staffName.isAcceptableOrUnknown(data['staff_name']!, _staffNameMeta),
      );
    } else if (isInserting) {
      context.missing(_staffNameMeta);
    }
    if (data.containsKey('approved_by')) {
      context.handle(
        _approvedByMeta,
        approvedBy.isAcceptableOrUnknown(data['approved_by']!, _approvedByMeta),
      );
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Refund map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Refund(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      orderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_number'],
      )!,
      linesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lines_json'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_amount'],
      )!,
      methodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method_id'],
      )!,
      methodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method_name'],
      )!,
      rateGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_group'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      restock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}restock'],
      )!,
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      )!,
      staffName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_name'],
      )!,
      approvedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approved_by'],
      ),
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RefundsTable createAlias(String alias) {
    return $RefundsTable(attachedDatabase, alias);
  }
}

class Refund extends DataClass implements Insertable<Refund> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String orderId;
  final String orderNumber;

  /// JSON list: [{"key":..,"name":..,"qty":..,"amount":..}]
  final String linesJson;
  final int amount;
  final int taxAmount;
  final String methodId;
  final String methodName;
  final String rateGroup;
  final String reason;
  final bool restock;
  final String staffId;
  final String staffName;
  final String? approvedBy;
  final String? shiftId;
  final String deviceId;
  final String businessDate;
  final int createdAt;
  const Refund({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.orderId,
    required this.orderNumber,
    required this.linesJson,
    required this.amount,
    required this.taxAmount,
    required this.methodId,
    required this.methodName,
    required this.rateGroup,
    required this.reason,
    required this.restock,
    required this.staffId,
    required this.staffName,
    this.approvedBy,
    this.shiftId,
    required this.deviceId,
    required this.businessDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['order_id'] = Variable<String>(orderId);
    map['order_number'] = Variable<String>(orderNumber);
    map['lines_json'] = Variable<String>(linesJson);
    map['amount'] = Variable<int>(amount);
    map['tax_amount'] = Variable<int>(taxAmount);
    map['method_id'] = Variable<String>(methodId);
    map['method_name'] = Variable<String>(methodName);
    map['rate_group'] = Variable<String>(rateGroup);
    map['reason'] = Variable<String>(reason);
    map['restock'] = Variable<bool>(restock);
    map['staff_id'] = Variable<String>(staffId);
    map['staff_name'] = Variable<String>(staffName);
    if (!nullToAbsent || approvedBy != null) {
      map['approved_by'] = Variable<String>(approvedBy);
    }
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<String>(shiftId);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['business_date'] = Variable<String>(businessDate);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  RefundsCompanion toCompanion(bool nullToAbsent) {
    return RefundsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      orderId: Value(orderId),
      orderNumber: Value(orderNumber),
      linesJson: Value(linesJson),
      amount: Value(amount),
      taxAmount: Value(taxAmount),
      methodId: Value(methodId),
      methodName: Value(methodName),
      rateGroup: Value(rateGroup),
      reason: Value(reason),
      restock: Value(restock),
      staffId: Value(staffId),
      staffName: Value(staffName),
      approvedBy: approvedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedBy),
      shiftId: shiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftId),
      deviceId: Value(deviceId),
      businessDate: Value(businessDate),
      createdAt: Value(createdAt),
    );
  }

  factory Refund.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Refund(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      orderId: serializer.fromJson<String>(json['orderId']),
      orderNumber: serializer.fromJson<String>(json['orderNumber']),
      linesJson: serializer.fromJson<String>(json['linesJson']),
      amount: serializer.fromJson<int>(json['amount']),
      taxAmount: serializer.fromJson<int>(json['taxAmount']),
      methodId: serializer.fromJson<String>(json['methodId']),
      methodName: serializer.fromJson<String>(json['methodName']),
      rateGroup: serializer.fromJson<String>(json['rateGroup']),
      reason: serializer.fromJson<String>(json['reason']),
      restock: serializer.fromJson<bool>(json['restock']),
      staffId: serializer.fromJson<String>(json['staffId']),
      staffName: serializer.fromJson<String>(json['staffName']),
      approvedBy: serializer.fromJson<String?>(json['approvedBy']),
      shiftId: serializer.fromJson<String?>(json['shiftId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'orderId': serializer.toJson<String>(orderId),
      'orderNumber': serializer.toJson<String>(orderNumber),
      'linesJson': serializer.toJson<String>(linesJson),
      'amount': serializer.toJson<int>(amount),
      'taxAmount': serializer.toJson<int>(taxAmount),
      'methodId': serializer.toJson<String>(methodId),
      'methodName': serializer.toJson<String>(methodName),
      'rateGroup': serializer.toJson<String>(rateGroup),
      'reason': serializer.toJson<String>(reason),
      'restock': serializer.toJson<bool>(restock),
      'staffId': serializer.toJson<String>(staffId),
      'staffName': serializer.toJson<String>(staffName),
      'approvedBy': serializer.toJson<String?>(approvedBy),
      'shiftId': serializer.toJson<String?>(shiftId),
      'deviceId': serializer.toJson<String>(deviceId),
      'businessDate': serializer.toJson<String>(businessDate),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Refund copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? orderId,
    String? orderNumber,
    String? linesJson,
    int? amount,
    int? taxAmount,
    String? methodId,
    String? methodName,
    String? rateGroup,
    String? reason,
    bool? restock,
    String? staffId,
    String? staffName,
    Value<String?> approvedBy = const Value.absent(),
    Value<String?> shiftId = const Value.absent(),
    String? deviceId,
    String? businessDate,
    int? createdAt,
  }) => Refund(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    orderId: orderId ?? this.orderId,
    orderNumber: orderNumber ?? this.orderNumber,
    linesJson: linesJson ?? this.linesJson,
    amount: amount ?? this.amount,
    taxAmount: taxAmount ?? this.taxAmount,
    methodId: methodId ?? this.methodId,
    methodName: methodName ?? this.methodName,
    rateGroup: rateGroup ?? this.rateGroup,
    reason: reason ?? this.reason,
    restock: restock ?? this.restock,
    staffId: staffId ?? this.staffId,
    staffName: staffName ?? this.staffName,
    approvedBy: approvedBy.present ? approvedBy.value : this.approvedBy,
    shiftId: shiftId.present ? shiftId.value : this.shiftId,
    deviceId: deviceId ?? this.deviceId,
    businessDate: businessDate ?? this.businessDate,
    createdAt: createdAt ?? this.createdAt,
  );
  Refund copyWithCompanion(RefundsCompanion data) {
    return Refund(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      orderNumber: data.orderNumber.present
          ? data.orderNumber.value
          : this.orderNumber,
      linesJson: data.linesJson.present ? data.linesJson.value : this.linesJson,
      amount: data.amount.present ? data.amount.value : this.amount,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      methodId: data.methodId.present ? data.methodId.value : this.methodId,
      methodName: data.methodName.present
          ? data.methodName.value
          : this.methodName,
      rateGroup: data.rateGroup.present ? data.rateGroup.value : this.rateGroup,
      reason: data.reason.present ? data.reason.value : this.reason,
      restock: data.restock.present ? data.restock.value : this.restock,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      staffName: data.staffName.present ? data.staffName.value : this.staffName,
      approvedBy: data.approvedBy.present
          ? data.approvedBy.value
          : this.approvedBy,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Refund(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('orderId: $orderId, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('linesJson: $linesJson, ')
          ..write('amount: $amount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('methodId: $methodId, ')
          ..write('methodName: $methodName, ')
          ..write('rateGroup: $rateGroup, ')
          ..write('reason: $reason, ')
          ..write('restock: $restock, ')
          ..write('staffId: $staffId, ')
          ..write('staffName: $staffName, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('shiftId: $shiftId, ')
          ..write('deviceId: $deviceId, ')
          ..write('businessDate: $businessDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    orderId,
    orderNumber,
    linesJson,
    amount,
    taxAmount,
    methodId,
    methodName,
    rateGroup,
    reason,
    restock,
    staffId,
    staffName,
    approvedBy,
    shiftId,
    deviceId,
    businessDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Refund &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.orderId == this.orderId &&
          other.orderNumber == this.orderNumber &&
          other.linesJson == this.linesJson &&
          other.amount == this.amount &&
          other.taxAmount == this.taxAmount &&
          other.methodId == this.methodId &&
          other.methodName == this.methodName &&
          other.rateGroup == this.rateGroup &&
          other.reason == this.reason &&
          other.restock == this.restock &&
          other.staffId == this.staffId &&
          other.staffName == this.staffName &&
          other.approvedBy == this.approvedBy &&
          other.shiftId == this.shiftId &&
          other.deviceId == this.deviceId &&
          other.businessDate == this.businessDate &&
          other.createdAt == this.createdAt);
}

class RefundsCompanion extends UpdateCompanion<Refund> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> orderId;
  final Value<String> orderNumber;
  final Value<String> linesJson;
  final Value<int> amount;
  final Value<int> taxAmount;
  final Value<String> methodId;
  final Value<String> methodName;
  final Value<String> rateGroup;
  final Value<String> reason;
  final Value<bool> restock;
  final Value<String> staffId;
  final Value<String> staffName;
  final Value<String?> approvedBy;
  final Value<String?> shiftId;
  final Value<String> deviceId;
  final Value<String> businessDate;
  final Value<int> createdAt;
  final Value<int> rowid;
  const RefundsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.orderId = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.linesJson = const Value.absent(),
    this.amount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.methodId = const Value.absent(),
    this.methodName = const Value.absent(),
    this.rateGroup = const Value.absent(),
    this.reason = const Value.absent(),
    this.restock = const Value.absent(),
    this.staffId = const Value.absent(),
    this.staffName = const Value.absent(),
    this.approvedBy = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefundsCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String orderId,
    required String orderNumber,
    required String linesJson,
    required int amount,
    required int taxAmount,
    required String methodId,
    required String methodName,
    required String rateGroup,
    required String reason,
    this.restock = const Value.absent(),
    required String staffId,
    required String staffName,
    this.approvedBy = const Value.absent(),
    this.shiftId = const Value.absent(),
    required String deviceId,
    required String businessDate,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       orderId = Value(orderId),
       orderNumber = Value(orderNumber),
       linesJson = Value(linesJson),
       amount = Value(amount),
       taxAmount = Value(taxAmount),
       methodId = Value(methodId),
       methodName = Value(methodName),
       rateGroup = Value(rateGroup),
       reason = Value(reason),
       staffId = Value(staffId),
       staffName = Value(staffName),
       deviceId = Value(deviceId),
       businessDate = Value(businessDate),
       createdAt = Value(createdAt);
  static Insertable<Refund> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? orderId,
    Expression<String>? orderNumber,
    Expression<String>? linesJson,
    Expression<int>? amount,
    Expression<int>? taxAmount,
    Expression<String>? methodId,
    Expression<String>? methodName,
    Expression<String>? rateGroup,
    Expression<String>? reason,
    Expression<bool>? restock,
    Expression<String>? staffId,
    Expression<String>? staffName,
    Expression<String>? approvedBy,
    Expression<String>? shiftId,
    Expression<String>? deviceId,
    Expression<String>? businessDate,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (orderId != null) 'order_id': orderId,
      if (orderNumber != null) 'order_number': orderNumber,
      if (linesJson != null) 'lines_json': linesJson,
      if (amount != null) 'amount': amount,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (methodId != null) 'method_id': methodId,
      if (methodName != null) 'method_name': methodName,
      if (rateGroup != null) 'rate_group': rateGroup,
      if (reason != null) 'reason': reason,
      if (restock != null) 'restock': restock,
      if (staffId != null) 'staff_id': staffId,
      if (staffName != null) 'staff_name': staffName,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (shiftId != null) 'shift_id': shiftId,
      if (deviceId != null) 'device_id': deviceId,
      if (businessDate != null) 'business_date': businessDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefundsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? orderId,
    Value<String>? orderNumber,
    Value<String>? linesJson,
    Value<int>? amount,
    Value<int>? taxAmount,
    Value<String>? methodId,
    Value<String>? methodName,
    Value<String>? rateGroup,
    Value<String>? reason,
    Value<bool>? restock,
    Value<String>? staffId,
    Value<String>? staffName,
    Value<String?>? approvedBy,
    Value<String?>? shiftId,
    Value<String>? deviceId,
    Value<String>? businessDate,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return RefundsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      linesJson: linesJson ?? this.linesJson,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      methodId: methodId ?? this.methodId,
      methodName: methodName ?? this.methodName,
      rateGroup: rateGroup ?? this.rateGroup,
      reason: reason ?? this.reason,
      restock: restock ?? this.restock,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      approvedBy: approvedBy ?? this.approvedBy,
      shiftId: shiftId ?? this.shiftId,
      deviceId: deviceId ?? this.deviceId,
      businessDate: businessDate ?? this.businessDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<String>(orderNumber.value);
    }
    if (linesJson.present) {
      map['lines_json'] = Variable<String>(linesJson.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<int>(taxAmount.value);
    }
    if (methodId.present) {
      map['method_id'] = Variable<String>(methodId.value);
    }
    if (methodName.present) {
      map['method_name'] = Variable<String>(methodName.value);
    }
    if (rateGroup.present) {
      map['rate_group'] = Variable<String>(rateGroup.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (restock.present) {
      map['restock'] = Variable<bool>(restock.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (staffName.present) {
      map['staff_name'] = Variable<String>(staffName.value);
    }
    if (approvedBy.present) {
      map['approved_by'] = Variable<String>(approvedBy.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefundsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('orderId: $orderId, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('linesJson: $linesJson, ')
          ..write('amount: $amount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('methodId: $methodId, ')
          ..write('methodName: $methodName, ')
          ..write('rateGroup: $rateGroup, ')
          ..write('reason: $reason, ')
          ..write('restock: $restock, ')
          ..write('staffId: $staffId, ')
          ..write('staffName: $staffName, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('shiftId: $shiftId, ')
          ..write('deviceId: $deviceId, ')
          ..write('businessDate: $businessDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, Shift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceCodeMeta = const VerificationMeta(
    'deviceCode',
  );
  @override
  late final GeneratedColumn<String> deviceCode = GeneratedColumn<String>(
    'device_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedByIdMeta = const VerificationMeta(
    'openedById',
  );
  @override
  late final GeneratedColumn<String> openedById = GeneratedColumn<String>(
    'opened_by_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedByNameMeta = const VerificationMeta(
    'openedByName',
  );
  @override
  late final GeneratedColumn<String> openedByName = GeneratedColumn<String>(
    'opened_by_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<int> openedAt = GeneratedColumn<int>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingFloatMeta = const VerificationMeta(
    'openingFloat',
  );
  @override
  late final GeneratedColumn<int> openingFloat = GeneratedColumn<int>(
    'opening_float',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedByIdMeta = const VerificationMeta(
    'closedById',
  );
  @override
  late final GeneratedColumn<String> closedById = GeneratedColumn<String>(
    'closed_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedByNameMeta = const VerificationMeta(
    'closedByName',
  );
  @override
  late final GeneratedColumn<String> closedByName = GeneratedColumn<String>(
    'closed_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<int> closedAt = GeneratedColumn<int>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countedCashMeta = const VerificationMeta(
    'countedCash',
  );
  @override
  late final GeneratedColumn<int> countedCash = GeneratedColumn<int>(
    'counted_cash',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedCashMeta = const VerificationMeta(
    'expectedCash',
  );
  @override
  late final GeneratedColumn<int> expectedCash = GeneratedColumn<int>(
    'expected_cash',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryJsonMeta = const VerificationMeta(
    'summaryJson',
  );
  @override
  late final GeneratedColumn<String> summaryJson = GeneratedColumn<String>(
    'summary_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    deviceId,
    deviceCode,
    status,
    openedById,
    openedByName,
    openedAt,
    openingFloat,
    closedById,
    closedByName,
    closedAt,
    countedCash,
    expectedCash,
    note,
    summaryJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shift> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_code')) {
      context.handle(
        _deviceCodeMeta,
        deviceCode.isAcceptableOrUnknown(data['device_code']!, _deviceCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceCodeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('opened_by_id')) {
      context.handle(
        _openedByIdMeta,
        openedById.isAcceptableOrUnknown(
          data['opened_by_id']!,
          _openedByIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openedByIdMeta);
    }
    if (data.containsKey('opened_by_name')) {
      context.handle(
        _openedByNameMeta,
        openedByName.isAcceptableOrUnknown(
          data['opened_by_name']!,
          _openedByNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openedByNameMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('opening_float')) {
      context.handle(
        _openingFloatMeta,
        openingFloat.isAcceptableOrUnknown(
          data['opening_float']!,
          _openingFloatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingFloatMeta);
    }
    if (data.containsKey('closed_by_id')) {
      context.handle(
        _closedByIdMeta,
        closedById.isAcceptableOrUnknown(
          data['closed_by_id']!,
          _closedByIdMeta,
        ),
      );
    }
    if (data.containsKey('closed_by_name')) {
      context.handle(
        _closedByNameMeta,
        closedByName.isAcceptableOrUnknown(
          data['closed_by_name']!,
          _closedByNameMeta,
        ),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('counted_cash')) {
      context.handle(
        _countedCashMeta,
        countedCash.isAcceptableOrUnknown(
          data['counted_cash']!,
          _countedCashMeta,
        ),
      );
    }
    if (data.containsKey('expected_cash')) {
      context.handle(
        _expectedCashMeta,
        expectedCash.isAcceptableOrUnknown(
          data['expected_cash']!,
          _expectedCashMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('summary_json')) {
      context.handle(
        _summaryJsonMeta,
        summaryJson.isAcceptableOrUnknown(
          data['summary_json']!,
          _summaryJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shift(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_code'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      openedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opened_by_id'],
      )!,
      openedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opened_by_name'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opened_at'],
      )!,
      openingFloat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_float'],
      )!,
      closedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by_id'],
      ),
      closedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by_name'],
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closed_at'],
      ),
      countedCash: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counted_cash'],
      ),
      expectedCash: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_cash'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      summaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_json'],
      ),
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }
}

class Shift extends DataClass implements Insertable<Shift> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String deviceId;
  final String deviceCode;

  /// 'open' | 'closed'
  final String status;
  final String openedById;
  final String openedByName;
  final int openedAt;
  final int openingFloat;
  final String? closedById;
  final String? closedByName;
  final int? closedAt;
  final int? countedCash;
  final int? expectedCash;
  final String? note;

  /// Frozen Z-report figures written when the shift closes.
  final String? summaryJson;
  const Shift({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.deviceId,
    required this.deviceCode,
    required this.status,
    required this.openedById,
    required this.openedByName,
    required this.openedAt,
    required this.openingFloat,
    this.closedById,
    this.closedByName,
    this.closedAt,
    this.countedCash,
    this.expectedCash,
    this.note,
    this.summaryJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['device_id'] = Variable<String>(deviceId);
    map['device_code'] = Variable<String>(deviceCode);
    map['status'] = Variable<String>(status);
    map['opened_by_id'] = Variable<String>(openedById);
    map['opened_by_name'] = Variable<String>(openedByName);
    map['opened_at'] = Variable<int>(openedAt);
    map['opening_float'] = Variable<int>(openingFloat);
    if (!nullToAbsent || closedById != null) {
      map['closed_by_id'] = Variable<String>(closedById);
    }
    if (!nullToAbsent || closedByName != null) {
      map['closed_by_name'] = Variable<String>(closedByName);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<int>(closedAt);
    }
    if (!nullToAbsent || countedCash != null) {
      map['counted_cash'] = Variable<int>(countedCash);
    }
    if (!nullToAbsent || expectedCash != null) {
      map['expected_cash'] = Variable<int>(expectedCash);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || summaryJson != null) {
      map['summary_json'] = Variable<String>(summaryJson);
    }
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      deviceId: Value(deviceId),
      deviceCode: Value(deviceCode),
      status: Value(status),
      openedById: Value(openedById),
      openedByName: Value(openedByName),
      openedAt: Value(openedAt),
      openingFloat: Value(openingFloat),
      closedById: closedById == null && nullToAbsent
          ? const Value.absent()
          : Value(closedById),
      closedByName: closedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(closedByName),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      countedCash: countedCash == null && nullToAbsent
          ? const Value.absent()
          : Value(countedCash),
      expectedCash: expectedCash == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedCash),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      summaryJson: summaryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryJson),
    );
  }

  factory Shift.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shift(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceCode: serializer.fromJson<String>(json['deviceCode']),
      status: serializer.fromJson<String>(json['status']),
      openedById: serializer.fromJson<String>(json['openedById']),
      openedByName: serializer.fromJson<String>(json['openedByName']),
      openedAt: serializer.fromJson<int>(json['openedAt']),
      openingFloat: serializer.fromJson<int>(json['openingFloat']),
      closedById: serializer.fromJson<String?>(json['closedById']),
      closedByName: serializer.fromJson<String?>(json['closedByName']),
      closedAt: serializer.fromJson<int?>(json['closedAt']),
      countedCash: serializer.fromJson<int?>(json['countedCash']),
      expectedCash: serializer.fromJson<int?>(json['expectedCash']),
      note: serializer.fromJson<String?>(json['note']),
      summaryJson: serializer.fromJson<String?>(json['summaryJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceCode': serializer.toJson<String>(deviceCode),
      'status': serializer.toJson<String>(status),
      'openedById': serializer.toJson<String>(openedById),
      'openedByName': serializer.toJson<String>(openedByName),
      'openedAt': serializer.toJson<int>(openedAt),
      'openingFloat': serializer.toJson<int>(openingFloat),
      'closedById': serializer.toJson<String?>(closedById),
      'closedByName': serializer.toJson<String?>(closedByName),
      'closedAt': serializer.toJson<int?>(closedAt),
      'countedCash': serializer.toJson<int?>(countedCash),
      'expectedCash': serializer.toJson<int?>(expectedCash),
      'note': serializer.toJson<String?>(note),
      'summaryJson': serializer.toJson<String?>(summaryJson),
    };
  }

  Shift copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? deviceId,
    String? deviceCode,
    String? status,
    String? openedById,
    String? openedByName,
    int? openedAt,
    int? openingFloat,
    Value<String?> closedById = const Value.absent(),
    Value<String?> closedByName = const Value.absent(),
    Value<int?> closedAt = const Value.absent(),
    Value<int?> countedCash = const Value.absent(),
    Value<int?> expectedCash = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> summaryJson = const Value.absent(),
  }) => Shift(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    deviceId: deviceId ?? this.deviceId,
    deviceCode: deviceCode ?? this.deviceCode,
    status: status ?? this.status,
    openedById: openedById ?? this.openedById,
    openedByName: openedByName ?? this.openedByName,
    openedAt: openedAt ?? this.openedAt,
    openingFloat: openingFloat ?? this.openingFloat,
    closedById: closedById.present ? closedById.value : this.closedById,
    closedByName: closedByName.present ? closedByName.value : this.closedByName,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    countedCash: countedCash.present ? countedCash.value : this.countedCash,
    expectedCash: expectedCash.present ? expectedCash.value : this.expectedCash,
    note: note.present ? note.value : this.note,
    summaryJson: summaryJson.present ? summaryJson.value : this.summaryJson,
  );
  Shift copyWithCompanion(ShiftsCompanion data) {
    return Shift(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceCode: data.deviceCode.present
          ? data.deviceCode.value
          : this.deviceCode,
      status: data.status.present ? data.status.value : this.status,
      openedById: data.openedById.present
          ? data.openedById.value
          : this.openedById,
      openedByName: data.openedByName.present
          ? data.openedByName.value
          : this.openedByName,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      openingFloat: data.openingFloat.present
          ? data.openingFloat.value
          : this.openingFloat,
      closedById: data.closedById.present
          ? data.closedById.value
          : this.closedById,
      closedByName: data.closedByName.present
          ? data.closedByName.value
          : this.closedByName,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      countedCash: data.countedCash.present
          ? data.countedCash.value
          : this.countedCash,
      expectedCash: data.expectedCash.present
          ? data.expectedCash.value
          : this.expectedCash,
      note: data.note.present ? data.note.value : this.note,
      summaryJson: data.summaryJson.present
          ? data.summaryJson.value
          : this.summaryJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shift(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceCode: $deviceCode, ')
          ..write('status: $status, ')
          ..write('openedById: $openedById, ')
          ..write('openedByName: $openedByName, ')
          ..write('openedAt: $openedAt, ')
          ..write('openingFloat: $openingFloat, ')
          ..write('closedById: $closedById, ')
          ..write('closedByName: $closedByName, ')
          ..write('closedAt: $closedAt, ')
          ..write('countedCash: $countedCash, ')
          ..write('expectedCash: $expectedCash, ')
          ..write('note: $note, ')
          ..write('summaryJson: $summaryJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    deviceId,
    deviceCode,
    status,
    openedById,
    openedByName,
    openedAt,
    openingFloat,
    closedById,
    closedByName,
    closedAt,
    countedCash,
    expectedCash,
    note,
    summaryJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shift &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.deviceId == this.deviceId &&
          other.deviceCode == this.deviceCode &&
          other.status == this.status &&
          other.openedById == this.openedById &&
          other.openedByName == this.openedByName &&
          other.openedAt == this.openedAt &&
          other.openingFloat == this.openingFloat &&
          other.closedById == this.closedById &&
          other.closedByName == this.closedByName &&
          other.closedAt == this.closedAt &&
          other.countedCash == this.countedCash &&
          other.expectedCash == this.expectedCash &&
          other.note == this.note &&
          other.summaryJson == this.summaryJson);
}

class ShiftsCompanion extends UpdateCompanion<Shift> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> deviceId;
  final Value<String> deviceCode;
  final Value<String> status;
  final Value<String> openedById;
  final Value<String> openedByName;
  final Value<int> openedAt;
  final Value<int> openingFloat;
  final Value<String?> closedById;
  final Value<String?> closedByName;
  final Value<int?> closedAt;
  final Value<int?> countedCash;
  final Value<int?> expectedCash;
  final Value<String?> note;
  final Value<String?> summaryJson;
  final Value<int> rowid;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceCode = const Value.absent(),
    this.status = const Value.absent(),
    this.openedById = const Value.absent(),
    this.openedByName = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.openingFloat = const Value.absent(),
    this.closedById = const Value.absent(),
    this.closedByName = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.countedCash = const Value.absent(),
    this.expectedCash = const Value.absent(),
    this.note = const Value.absent(),
    this.summaryJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String deviceId,
    required String deviceCode,
    required String status,
    required String openedById,
    required String openedByName,
    required int openedAt,
    required int openingFloat,
    this.closedById = const Value.absent(),
    this.closedByName = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.countedCash = const Value.absent(),
    this.expectedCash = const Value.absent(),
    this.note = const Value.absent(),
    this.summaryJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       deviceCode = Value(deviceCode),
       status = Value(status),
       openedById = Value(openedById),
       openedByName = Value(openedByName),
       openedAt = Value(openedAt),
       openingFloat = Value(openingFloat);
  static Insertable<Shift> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? deviceId,
    Expression<String>? deviceCode,
    Expression<String>? status,
    Expression<String>? openedById,
    Expression<String>? openedByName,
    Expression<int>? openedAt,
    Expression<int>? openingFloat,
    Expression<String>? closedById,
    Expression<String>? closedByName,
    Expression<int>? closedAt,
    Expression<int>? countedCash,
    Expression<int>? expectedCash,
    Expression<String>? note,
    Expression<String>? summaryJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceCode != null) 'device_code': deviceCode,
      if (status != null) 'status': status,
      if (openedById != null) 'opened_by_id': openedById,
      if (openedByName != null) 'opened_by_name': openedByName,
      if (openedAt != null) 'opened_at': openedAt,
      if (openingFloat != null) 'opening_float': openingFloat,
      if (closedById != null) 'closed_by_id': closedById,
      if (closedByName != null) 'closed_by_name': closedByName,
      if (closedAt != null) 'closed_at': closedAt,
      if (countedCash != null) 'counted_cash': countedCash,
      if (expectedCash != null) 'expected_cash': expectedCash,
      if (note != null) 'note': note,
      if (summaryJson != null) 'summary_json': summaryJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? deviceId,
    Value<String>? deviceCode,
    Value<String>? status,
    Value<String>? openedById,
    Value<String>? openedByName,
    Value<int>? openedAt,
    Value<int>? openingFloat,
    Value<String?>? closedById,
    Value<String?>? closedByName,
    Value<int?>? closedAt,
    Value<int?>? countedCash,
    Value<int?>? expectedCash,
    Value<String?>? note,
    Value<String?>? summaryJson,
    Value<int>? rowid,
  }) {
    return ShiftsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      deviceId: deviceId ?? this.deviceId,
      deviceCode: deviceCode ?? this.deviceCode,
      status: status ?? this.status,
      openedById: openedById ?? this.openedById,
      openedByName: openedByName ?? this.openedByName,
      openedAt: openedAt ?? this.openedAt,
      openingFloat: openingFloat ?? this.openingFloat,
      closedById: closedById ?? this.closedById,
      closedByName: closedByName ?? this.closedByName,
      closedAt: closedAt ?? this.closedAt,
      countedCash: countedCash ?? this.countedCash,
      expectedCash: expectedCash ?? this.expectedCash,
      note: note ?? this.note,
      summaryJson: summaryJson ?? this.summaryJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceCode.present) {
      map['device_code'] = Variable<String>(deviceCode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (openedById.present) {
      map['opened_by_id'] = Variable<String>(openedById.value);
    }
    if (openedByName.present) {
      map['opened_by_name'] = Variable<String>(openedByName.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<int>(openedAt.value);
    }
    if (openingFloat.present) {
      map['opening_float'] = Variable<int>(openingFloat.value);
    }
    if (closedById.present) {
      map['closed_by_id'] = Variable<String>(closedById.value);
    }
    if (closedByName.present) {
      map['closed_by_name'] = Variable<String>(closedByName.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<int>(closedAt.value);
    }
    if (countedCash.present) {
      map['counted_cash'] = Variable<int>(countedCash.value);
    }
    if (expectedCash.present) {
      map['expected_cash'] = Variable<int>(expectedCash.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (summaryJson.present) {
      map['summary_json'] = Variable<String>(summaryJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceCode: $deviceCode, ')
          ..write('status: $status, ')
          ..write('openedById: $openedById, ')
          ..write('openedByName: $openedByName, ')
          ..write('openedAt: $openedAt, ')
          ..write('openingFloat: $openingFloat, ')
          ..write('closedById: $closedById, ')
          ..write('closedByName: $closedByName, ')
          ..write('closedAt: $closedAt, ')
          ..write('countedCash: $countedCash, ')
          ..write('expectedCash: $expectedCash, ')
          ..write('note: $note, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashMovementsTable extends CashMovements
    with TableInfo<$CashMovementsTable, CashMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _staffNameMeta = const VerificationMeta(
    'staffName',
  );
  @override
  late final GeneratedColumn<String> staffName = GeneratedColumn<String>(
    'staff_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    shiftId,
    type,
    amount,
    reason,
    staffId,
    staffName,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('staff_name')) {
      context.handle(
        _staffNameMeta,
        staffName.isAcceptableOrUnknown(data['staff_name']!, _staffNameMeta),
      );
    } else if (isInserting) {
      context.missing(_staffNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      )!,
      staffName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CashMovementsTable createAlias(String alias) {
    return $CashMovementsTable(attachedDatabase, alias);
  }
}

class CashMovement extends DataClass implements Insertable<CashMovement> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String shiftId;

  /// 'in' | 'out'
  final String type;
  final int amount;
  final String reason;
  final String staffId;
  final String staffName;
  final int createdAt;
  const CashMovement({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.shiftId,
    required this.type,
    required this.amount,
    required this.reason,
    required this.staffId,
    required this.staffName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['shift_id'] = Variable<String>(shiftId);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<int>(amount);
    map['reason'] = Variable<String>(reason);
    map['staff_id'] = Variable<String>(staffId);
    map['staff_name'] = Variable<String>(staffName);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CashMovementsCompanion toCompanion(bool nullToAbsent) {
    return CashMovementsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      shiftId: Value(shiftId),
      type: Value(type),
      amount: Value(amount),
      reason: Value(reason),
      staffId: Value(staffId),
      staffName: Value(staffName),
      createdAt: Value(createdAt),
    );
  }

  factory CashMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashMovement(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      reason: serializer.fromJson<String>(json['reason']),
      staffId: serializer.fromJson<String>(json['staffId']),
      staffName: serializer.fromJson<String>(json['staffName']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'shiftId': serializer.toJson<String>(shiftId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<int>(amount),
      'reason': serializer.toJson<String>(reason),
      'staffId': serializer.toJson<String>(staffId),
      'staffName': serializer.toJson<String>(staffName),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CashMovement copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? shiftId,
    String? type,
    int? amount,
    String? reason,
    String? staffId,
    String? staffName,
    int? createdAt,
  }) => CashMovement(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    shiftId: shiftId ?? this.shiftId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    reason: reason ?? this.reason,
    staffId: staffId ?? this.staffId,
    staffName: staffName ?? this.staffName,
    createdAt: createdAt ?? this.createdAt,
  );
  CashMovement copyWithCompanion(CashMovementsCompanion data) {
    return CashMovement(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      staffName: data.staffName.present ? data.staffName.value : this.staffName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashMovement(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('shiftId: $shiftId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('staffId: $staffId, ')
          ..write('staffName: $staffName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    shiftId,
    type,
    amount,
    reason,
    staffId,
    staffName,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashMovement &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.shiftId == this.shiftId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.staffId == this.staffId &&
          other.staffName == this.staffName &&
          other.createdAt == this.createdAt);
}

class CashMovementsCompanion extends UpdateCompanion<CashMovement> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> shiftId;
  final Value<String> type;
  final Value<int> amount;
  final Value<String> reason;
  final Value<String> staffId;
  final Value<String> staffName;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CashMovementsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.staffId = const Value.absent(),
    this.staffName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashMovementsCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String shiftId,
    required String type,
    required int amount,
    required String reason,
    required String staffId,
    required String staffName,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       shiftId = Value(shiftId),
       type = Value(type),
       amount = Value(amount),
       reason = Value(reason),
       staffId = Value(staffId),
       staffName = Value(staffName),
       createdAt = Value(createdAt);
  static Insertable<CashMovement> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? shiftId,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<String>? reason,
    Expression<String>? staffId,
    Expression<String>? staffName,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (shiftId != null) 'shift_id': shiftId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (staffId != null) 'staff_id': staffId,
      if (staffName != null) 'staff_name': staffName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashMovementsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? shiftId,
    Value<String>? type,
    Value<int>? amount,
    Value<String>? reason,
    Value<String>? staffId,
    Value<String>? staffName,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CashMovementsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      shiftId: shiftId ?? this.shiftId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (staffName.present) {
      map['staff_name'] = Variable<String>(staffName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashMovementsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('shiftId: $shiftId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('staffId: $staffId, ')
          ..write('staffName: $staffName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockItemsTable extends StockItems
    with TableInfo<$StockItemsTable, StockItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('General'),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reorderLevelMeta = const VerificationMeta(
    'reorderLevel',
  );
  @override
  late final GeneratedColumn<double> reorderLevel = GeneratedColumn<double>(
    'reorder_level',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _parLevelMeta = const VerificationMeta(
    'parLevel',
  );
  @override
  late final GeneratedColumn<double> parLevel = GeneratedColumn<double>(
    'par_level',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _costPerUnitMeta = const VerificationMeta(
    'costPerUnit',
  );
  @override
  late final GeneratedColumn<int> costPerUnit = GeneratedColumn<int>(
    'cost_per_unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('inventory'),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    name,
    groupName,
    unit,
    reorderLevel,
    parLevel,
    costPerUnit,
    icon,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
        _reorderLevelMeta,
        reorderLevel.isAcceptableOrUnknown(
          data['reorder_level']!,
          _reorderLevelMeta,
        ),
      );
    }
    if (data.containsKey('par_level')) {
      context.handle(
        _parLevelMeta,
        parLevel.isAcceptableOrUnknown(data['par_level']!, _parLevelMeta),
      );
    }
    if (data.containsKey('cost_per_unit')) {
      context.handle(
        _costPerUnitMeta,
        costPerUnit.isAcceptableOrUnknown(
          data['cost_per_unit']!,
          _costPerUnitMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      reorderLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reorder_level'],
      )!,
      parLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}par_level'],
      )!,
      costPerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_per_unit'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $StockItemsTable createAlias(String alias) {
    return $StockItemsTable(attachedDatabase, alias);
  }
}

class StockItem extends DataClass implements Insertable<StockItem> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String name;

  /// Group shown in the list, e.g. Coffee, Dairy, Bakery, Packaging.
  final String groupName;

  /// Base unit for quantities: 'g' | 'ml' | 'pcs'.
  final String unit;

  /// Quantities below this need reordering (base units).
  final double reorderLevel;

  /// Target level used for suggested purchase quantities (base units).
  final double parLevel;

  /// Cost in paisa per purchase unit (kg for g, L for ml, piece for pcs).
  final int costPerUnit;
  final String icon;
  final bool active;
  const StockItem({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.groupName,
    required this.unit,
    required this.reorderLevel,
    required this.parLevel,
    required this.costPerUnit,
    required this.icon,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['group_name'] = Variable<String>(groupName);
    map['unit'] = Variable<String>(unit);
    map['reorder_level'] = Variable<double>(reorderLevel);
    map['par_level'] = Variable<double>(parLevel);
    map['cost_per_unit'] = Variable<int>(costPerUnit);
    map['icon'] = Variable<String>(icon);
    map['active'] = Variable<bool>(active);
    return map;
  }

  StockItemsCompanion toCompanion(bool nullToAbsent) {
    return StockItemsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      groupName: Value(groupName),
      unit: Value(unit),
      reorderLevel: Value(reorderLevel),
      parLevel: Value(parLevel),
      costPerUnit: Value(costPerUnit),
      icon: Value(icon),
      active: Value(active),
    );
  }

  factory StockItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockItem(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      groupName: serializer.fromJson<String>(json['groupName']),
      unit: serializer.fromJson<String>(json['unit']),
      reorderLevel: serializer.fromJson<double>(json['reorderLevel']),
      parLevel: serializer.fromJson<double>(json['parLevel']),
      costPerUnit: serializer.fromJson<int>(json['costPerUnit']),
      icon: serializer.fromJson<String>(json['icon']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'groupName': serializer.toJson<String>(groupName),
      'unit': serializer.toJson<String>(unit),
      'reorderLevel': serializer.toJson<double>(reorderLevel),
      'parLevel': serializer.toJson<double>(parLevel),
      'costPerUnit': serializer.toJson<int>(costPerUnit),
      'icon': serializer.toJson<String>(icon),
      'active': serializer.toJson<bool>(active),
    };
  }

  StockItem copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? name,
    String? groupName,
    String? unit,
    double? reorderLevel,
    double? parLevel,
    int? costPerUnit,
    String? icon,
    bool? active,
  }) => StockItem(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    groupName: groupName ?? this.groupName,
    unit: unit ?? this.unit,
    reorderLevel: reorderLevel ?? this.reorderLevel,
    parLevel: parLevel ?? this.parLevel,
    costPerUnit: costPerUnit ?? this.costPerUnit,
    icon: icon ?? this.icon,
    active: active ?? this.active,
  );
  StockItem copyWithCompanion(StockItemsCompanion data) {
    return StockItem(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      unit: data.unit.present ? data.unit.value : this.unit,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      parLevel: data.parLevel.present ? data.parLevel.value : this.parLevel,
      costPerUnit: data.costPerUnit.present
          ? data.costPerUnit.value
          : this.costPerUnit,
      icon: data.icon.present ? data.icon.value : this.icon,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockItem(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('groupName: $groupName, ')
          ..write('unit: $unit, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('parLevel: $parLevel, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('icon: $icon, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    name,
    groupName,
    unit,
    reorderLevel,
    parLevel,
    costPerUnit,
    icon,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockItem &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.groupName == this.groupName &&
          other.unit == this.unit &&
          other.reorderLevel == this.reorderLevel &&
          other.parLevel == this.parLevel &&
          other.costPerUnit == this.costPerUnit &&
          other.icon == this.icon &&
          other.active == this.active);
}

class StockItemsCompanion extends UpdateCompanion<StockItem> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> groupName;
  final Value<String> unit;
  final Value<double> reorderLevel;
  final Value<double> parLevel;
  final Value<int> costPerUnit;
  final Value<String> icon;
  final Value<bool> active;
  final Value<int> rowid;
  const StockItemsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.groupName = const Value.absent(),
    this.unit = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.parLevel = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.icon = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockItemsCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    this.groupName = const Value.absent(),
    required String unit,
    this.reorderLevel = const Value.absent(),
    this.parLevel = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.icon = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       name = Value(name),
       unit = Value(unit);
  static Insertable<StockItem> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? groupName,
    Expression<String>? unit,
    Expression<double>? reorderLevel,
    Expression<double>? parLevel,
    Expression<int>? costPerUnit,
    Expression<String>? icon,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (groupName != null) 'group_name': groupName,
      if (unit != null) 'unit': unit,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (parLevel != null) 'par_level': parLevel,
      if (costPerUnit != null) 'cost_per_unit': costPerUnit,
      if (icon != null) 'icon': icon,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockItemsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? groupName,
    Value<String>? unit,
    Value<double>? reorderLevel,
    Value<double>? parLevel,
    Value<int>? costPerUnit,
    Value<String>? icon,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return StockItemsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      groupName: groupName ?? this.groupName,
      unit: unit ?? this.unit,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      parLevel: parLevel ?? this.parLevel,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      icon: icon ?? this.icon,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<double>(reorderLevel.value);
    }
    if (parLevel.present) {
      map['par_level'] = Variable<double>(parLevel.value);
    }
    if (costPerUnit.present) {
      map['cost_per_unit'] = Variable<int>(costPerUnit.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockItemsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('groupName: $groupName, ')
          ..write('unit: $unit, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('parLevel: $parLevel, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('icon: $icon, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeCodeMeta = const VerificationMeta(
    'sizeCode',
  );
  @override
  late final GeneratedColumn<String> sizeCode = GeneratedColumn<String>(
    'size_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _itemsJsonMeta = const VerificationMeta(
    'itemsJson',
  );
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
    'items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    productId,
    sizeCode,
    itemsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('size_code')) {
      context.handle(
        _sizeCodeMeta,
        sizeCode.isAcceptableOrUnknown(data['size_code']!, _sizeCodeMeta),
      );
    }
    if (data.containsKey('items_json')) {
      context.handle(
        _itemsJsonMeta,
        itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      sizeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size_code'],
      )!,
      itemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items_json'],
      )!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String productId;

  /// Size code this recipe is for; empty = all sizes (scaled S 0.8 / L 1.3 when no size recipe).
  final String sizeCode;

  /// JSON list: [{"stockItemId":"beans","qty":18}]
  final String itemsJson;
  const Recipe({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.productId,
    required this.sizeCode,
    required this.itemsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['product_id'] = Variable<String>(productId);
    map['size_code'] = Variable<String>(sizeCode);
    map['items_json'] = Variable<String>(itemsJson);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      productId: Value(productId),
      sizeCode: Value(sizeCode),
      itemsJson: Value(itemsJson),
    );
  }

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      productId: serializer.fromJson<String>(json['productId']),
      sizeCode: serializer.fromJson<String>(json['sizeCode']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'productId': serializer.toJson<String>(productId),
      'sizeCode': serializer.toJson<String>(sizeCode),
      'itemsJson': serializer.toJson<String>(itemsJson),
    };
  }

  Recipe copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? productId,
    String? sizeCode,
    String? itemsJson,
  }) => Recipe(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    productId: productId ?? this.productId,
    sizeCode: sizeCode ?? this.sizeCode,
    itemsJson: itemsJson ?? this.itemsJson,
  );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      productId: data.productId.present ? data.productId.value : this.productId,
      sizeCode: data.sizeCode.present ? data.sizeCode.value : this.sizeCode,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('productId: $productId, ')
          ..write('sizeCode: $sizeCode, ')
          ..write('itemsJson: $itemsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, deleted, productId, sizeCode, itemsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.productId == this.productId &&
          other.sizeCode == this.sizeCode &&
          other.itemsJson == this.itemsJson);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> productId;
  final Value<String> sizeCode;
  final Value<String> itemsJson;
  final Value<int> rowid;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.productId = const Value.absent(),
    this.sizeCode = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String productId,
    this.sizeCode = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       productId = Value(productId);
  static Insertable<Recipe> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? productId,
    Expression<String>? sizeCode,
    Expression<String>? itemsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (productId != null) 'product_id': productId,
      if (sizeCode != null) 'size_code': sizeCode,
      if (itemsJson != null) 'items_json': itemsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? productId,
    Value<String>? sizeCode,
    Value<String>? itemsJson,
    Value<int>? rowid,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      productId: productId ?? this.productId,
      sizeCode: sizeCode ?? this.sizeCode,
      itemsJson: itemsJson ?? this.itemsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (sizeCode.present) {
      map['size_code'] = Variable<String>(sizeCode.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('productId: $productId, ')
          ..write('sizeCode: $sizeCode, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _stockItemIdMeta = const VerificationMeta(
    'stockItemId',
  );
  @override
  late final GeneratedColumn<String> stockItemId = GeneratedColumn<String>(
    'stock_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<double> qty = GeneratedColumn<double>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<int> unitCost = GeneratedColumn<int>(
    'unit_cost',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _staffNameMeta = const VerificationMeta(
    'staffName',
  );
  @override
  late final GeneratedColumn<String> staffName = GeneratedColumn<String>(
    'staff_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    stockItemId,
    qty,
    type,
    refId,
    note,
    unitCost,
    staffId,
    staffName,
    deviceId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('stock_item_id')) {
      context.handle(
        _stockItemIdMeta,
        stockItemId.isAcceptableOrUnknown(
          data['stock_item_id']!,
          _stockItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockItemIdMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('ref_id')) {
      context.handle(
        _refIdMeta,
        refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    }
    if (data.containsKey('staff_name')) {
      context.handle(
        _staffNameMeta,
        staffName.isAcceptableOrUnknown(data['staff_name']!, _staffNameMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      stockItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_item_id'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}qty'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost'],
      ),
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      ),
      staffName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_name'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String stockItemId;

  /// Signed quantity in base units.
  final double qty;

  /// 'opening' | 'sale' | 'stockIn' | 'wastage' | 'count' | 'refund' | 'void'
  final String type;
  final String? refId;
  final String? note;

  /// Paisa per purchase unit for stock-ins.
  final int? unitCost;
  final String? staffId;
  final String? staffName;
  final String? deviceId;
  final int createdAt;
  const StockMovement({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.stockItemId,
    required this.qty,
    required this.type,
    this.refId,
    this.note,
    this.unitCost,
    this.staffId,
    this.staffName,
    this.deviceId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['stock_item_id'] = Variable<String>(stockItemId);
    map['qty'] = Variable<double>(qty);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<String>(refId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || unitCost != null) {
      map['unit_cost'] = Variable<int>(unitCost);
    }
    if (!nullToAbsent || staffId != null) {
      map['staff_id'] = Variable<String>(staffId);
    }
    if (!nullToAbsent || staffName != null) {
      map['staff_name'] = Variable<String>(staffName);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      stockItemId: Value(stockItemId),
      qty: Value(qty),
      type: Value(type),
      refId: refId == null && nullToAbsent
          ? const Value.absent()
          : Value(refId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      unitCost: unitCost == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCost),
      staffId: staffId == null && nullToAbsent
          ? const Value.absent()
          : Value(staffId),
      staffName: staffName == null && nullToAbsent
          ? const Value.absent()
          : Value(staffName),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
    );
  }

  factory StockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      stockItemId: serializer.fromJson<String>(json['stockItemId']),
      qty: serializer.fromJson<double>(json['qty']),
      type: serializer.fromJson<String>(json['type']),
      refId: serializer.fromJson<String?>(json['refId']),
      note: serializer.fromJson<String?>(json['note']),
      unitCost: serializer.fromJson<int?>(json['unitCost']),
      staffId: serializer.fromJson<String?>(json['staffId']),
      staffName: serializer.fromJson<String?>(json['staffName']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'stockItemId': serializer.toJson<String>(stockItemId),
      'qty': serializer.toJson<double>(qty),
      'type': serializer.toJson<String>(type),
      'refId': serializer.toJson<String?>(refId),
      'note': serializer.toJson<String?>(note),
      'unitCost': serializer.toJson<int?>(unitCost),
      'staffId': serializer.toJson<String?>(staffId),
      'staffName': serializer.toJson<String?>(staffName),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  StockMovement copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? stockItemId,
    double? qty,
    String? type,
    Value<String?> refId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<int?> unitCost = const Value.absent(),
    Value<String?> staffId = const Value.absent(),
    Value<String?> staffName = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    int? createdAt,
  }) => StockMovement(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    stockItemId: stockItemId ?? this.stockItemId,
    qty: qty ?? this.qty,
    type: type ?? this.type,
    refId: refId.present ? refId.value : this.refId,
    note: note.present ? note.value : this.note,
    unitCost: unitCost.present ? unitCost.value : this.unitCost,
    staffId: staffId.present ? staffId.value : this.staffId,
    staffName: staffName.present ? staffName.value : this.staffName,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
  );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      stockItemId: data.stockItemId.present
          ? data.stockItemId.value
          : this.stockItemId,
      qty: data.qty.present ? data.qty.value : this.qty,
      type: data.type.present ? data.type.value : this.type,
      refId: data.refId.present ? data.refId.value : this.refId,
      note: data.note.present ? data.note.value : this.note,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      staffName: data.staffName.present ? data.staffName.value : this.staffName,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('stockItemId: $stockItemId, ')
          ..write('qty: $qty, ')
          ..write('type: $type, ')
          ..write('refId: $refId, ')
          ..write('note: $note, ')
          ..write('unitCost: $unitCost, ')
          ..write('staffId: $staffId, ')
          ..write('staffName: $staffName, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    stockItemId,
    qty,
    type,
    refId,
    note,
    unitCost,
    staffId,
    staffName,
    deviceId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.stockItemId == this.stockItemId &&
          other.qty == this.qty &&
          other.type == this.type &&
          other.refId == this.refId &&
          other.note == this.note &&
          other.unitCost == this.unitCost &&
          other.staffId == this.staffId &&
          other.staffName == this.staffName &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> stockItemId;
  final Value<double> qty;
  final Value<String> type;
  final Value<String?> refId;
  final Value<String?> note;
  final Value<int?> unitCost;
  final Value<String?> staffId;
  final Value<String?> staffName;
  final Value<String?> deviceId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.stockItemId = const Value.absent(),
    this.qty = const Value.absent(),
    this.type = const Value.absent(),
    this.refId = const Value.absent(),
    this.note = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.staffId = const Value.absent(),
    this.staffName = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String stockItemId,
    required double qty,
    required String type,
    this.refId = const Value.absent(),
    this.note = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.staffId = const Value.absent(),
    this.staffName = const Value.absent(),
    this.deviceId = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       stockItemId = Value(stockItemId),
       qty = Value(qty),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<StockMovement> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? stockItemId,
    Expression<double>? qty,
    Expression<String>? type,
    Expression<String>? refId,
    Expression<String>? note,
    Expression<int>? unitCost,
    Expression<String>? staffId,
    Expression<String>? staffName,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (stockItemId != null) 'stock_item_id': stockItemId,
      if (qty != null) 'qty': qty,
      if (type != null) 'type': type,
      if (refId != null) 'ref_id': refId,
      if (note != null) 'note': note,
      if (unitCost != null) 'unit_cost': unitCost,
      if (staffId != null) 'staff_id': staffId,
      if (staffName != null) 'staff_name': staffName,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? stockItemId,
    Value<double>? qty,
    Value<String>? type,
    Value<String?>? refId,
    Value<String?>? note,
    Value<int?>? unitCost,
    Value<String?>? staffId,
    Value<String?>? staffName,
    Value<String?>? deviceId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      stockItemId: stockItemId ?? this.stockItemId,
      qty: qty ?? this.qty,
      type: type ?? this.type,
      refId: refId ?? this.refId,
      note: note ?? this.note,
      unitCost: unitCost ?? this.unitCost,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (stockItemId.present) {
      map['stock_item_id'] = Variable<String>(stockItemId.value);
    }
    if (qty.present) {
      map['qty'] = Variable<double>(qty.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<int>(unitCost.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (staffName.present) {
      map['staff_name'] = Variable<String>(staffName.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('stockItemId: $stockItemId, ')
          ..write('qty: $qty, ')
          ..write('type: $type, ')
          ..write('refId: $refId, ')
          ..write('note: $note, ')
          ..write('unitCost: $unitCost, ')
          ..write('staffId: $staffId, ')
          ..write('staffName: $staffName, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _staffNameMeta = const VerificationMeta(
    'staffName',
  );
  @override
  late final GeneratedColumn<String> staffName = GeneratedColumn<String>(
    'staff_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _approvedByIdMeta = const VerificationMeta(
    'approvedById',
  );
  @override
  late final GeneratedColumn<String> approvedById = GeneratedColumn<String>(
    'approved_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _approvedByNameMeta = const VerificationMeta(
    'approvedByName',
  );
  @override
  late final GeneratedColumn<String> approvedByName = GeneratedColumn<String>(
    'approved_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    action,
    staffId,
    staffName,
    approvedById,
    approvedByName,
    detailsJson,
    deviceId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('staff_name')) {
      context.handle(
        _staffNameMeta,
        staffName.isAcceptableOrUnknown(data['staff_name']!, _staffNameMeta),
      );
    } else if (isInserting) {
      context.missing(_staffNameMeta);
    }
    if (data.containsKey('approved_by_id')) {
      context.handle(
        _approvedByIdMeta,
        approvedById.isAcceptableOrUnknown(
          data['approved_by_id']!,
          _approvedByIdMeta,
        ),
      );
    }
    if (data.containsKey('approved_by_name')) {
      context.handle(
        _approvedByNameMeta,
        approvedByName.isAcceptableOrUnknown(
          data['approved_by_name']!,
          _approvedByNameMeta,
        ),
      );
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      )!,
      staffName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_name'],
      )!,
      approvedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approved_by_id'],
      ),
      approvedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approved_by_name'],
      ),
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String action;
  final String staffId;
  final String staffName;
  final String? approvedById;
  final String? approvedByName;
  final String detailsJson;
  final String? deviceId;
  final int createdAt;
  const AuditLog({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.action,
    required this.staffId,
    required this.staffName,
    this.approvedById,
    this.approvedByName,
    required this.detailsJson,
    this.deviceId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['action'] = Variable<String>(action);
    map['staff_id'] = Variable<String>(staffId);
    map['staff_name'] = Variable<String>(staffName);
    if (!nullToAbsent || approvedById != null) {
      map['approved_by_id'] = Variable<String>(approvedById);
    }
    if (!nullToAbsent || approvedByName != null) {
      map['approved_by_name'] = Variable<String>(approvedByName);
    }
    map['details_json'] = Variable<String>(detailsJson);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      action: Value(action),
      staffId: Value(staffId),
      staffName: Value(staffName),
      approvedById: approvedById == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedById),
      approvedByName: approvedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedByName),
      detailsJson: Value(detailsJson),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      action: serializer.fromJson<String>(json['action']),
      staffId: serializer.fromJson<String>(json['staffId']),
      staffName: serializer.fromJson<String>(json['staffName']),
      approvedById: serializer.fromJson<String?>(json['approvedById']),
      approvedByName: serializer.fromJson<String?>(json['approvedByName']),
      detailsJson: serializer.fromJson<String>(json['detailsJson']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'action': serializer.toJson<String>(action),
      'staffId': serializer.toJson<String>(staffId),
      'staffName': serializer.toJson<String>(staffName),
      'approvedById': serializer.toJson<String?>(approvedById),
      'approvedByName': serializer.toJson<String?>(approvedByName),
      'detailsJson': serializer.toJson<String>(detailsJson),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AuditLog copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? action,
    String? staffId,
    String? staffName,
    Value<String?> approvedById = const Value.absent(),
    Value<String?> approvedByName = const Value.absent(),
    String? detailsJson,
    Value<String?> deviceId = const Value.absent(),
    int? createdAt,
  }) => AuditLog(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    action: action ?? this.action,
    staffId: staffId ?? this.staffId,
    staffName: staffName ?? this.staffName,
    approvedById: approvedById.present ? approvedById.value : this.approvedById,
    approvedByName: approvedByName.present
        ? approvedByName.value
        : this.approvedByName,
    detailsJson: detailsJson ?? this.detailsJson,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      action: data.action.present ? data.action.value : this.action,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      staffName: data.staffName.present ? data.staffName.value : this.staffName,
      approvedById: data.approvedById.present
          ? data.approvedById.value
          : this.approvedById,
      approvedByName: data.approvedByName.present
          ? data.approvedByName.value
          : this.approvedByName,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('action: $action, ')
          ..write('staffId: $staffId, ')
          ..write('staffName: $staffName, ')
          ..write('approvedById: $approvedById, ')
          ..write('approvedByName: $approvedByName, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deleted,
    action,
    staffId,
    staffName,
    approvedById,
    approvedByName,
    detailsJson,
    deviceId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.action == this.action &&
          other.staffId == this.staffId &&
          other.staffName == this.staffName &&
          other.approvedById == this.approvedById &&
          other.approvedByName == this.approvedByName &&
          other.detailsJson == this.detailsJson &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> action;
  final Value<String> staffId;
  final Value<String> staffName;
  final Value<String?> approvedById;
  final Value<String?> approvedByName;
  final Value<String> detailsJson;
  final Value<String?> deviceId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.action = const Value.absent(),
    this.staffId = const Value.absent(),
    this.staffName = const Value.absent(),
    this.approvedById = const Value.absent(),
    this.approvedByName = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String action,
    required String staffId,
    required String staffName,
    this.approvedById = const Value.absent(),
    this.approvedByName = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.deviceId = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       action = Value(action),
       staffId = Value(staffId),
       staffName = Value(staffName),
       createdAt = Value(createdAt);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? action,
    Expression<String>? staffId,
    Expression<String>? staffName,
    Expression<String>? approvedById,
    Expression<String>? approvedByName,
    Expression<String>? detailsJson,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (action != null) 'action': action,
      if (staffId != null) 'staff_id': staffId,
      if (staffName != null) 'staff_name': staffName,
      if (approvedById != null) 'approved_by_id': approvedById,
      if (approvedByName != null) 'approved_by_name': approvedByName,
      if (detailsJson != null) 'details_json': detailsJson,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? action,
    Value<String>? staffId,
    Value<String>? staffName,
    Value<String?>? approvedById,
    Value<String?>? approvedByName,
    Value<String>? detailsJson,
    Value<String?>? deviceId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      action: action ?? this.action,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      approvedById: approvedById ?? this.approvedById,
      approvedByName: approvedByName ?? this.approvedByName,
      detailsJson: detailsJson ?? this.detailsJson,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (staffName.present) {
      map['staff_name'] = Variable<String>(staffName.value);
    }
    if (approvedById.present) {
      map['approved_by_id'] = Variable<String>(approvedById.value);
    }
    if (approvedByName.present) {
      map['approved_by_name'] = Variable<String>(approvedByName.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('action: $action, ')
          ..write('staffId: $staffId, ')
          ..write('staffName: $staffName, ')
          ..write('approvedById: $approvedById, ')
          ..write('approvedByName: $approvedByName, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsEntriesTable extends SettingsEntries
    with TableInfo<$SettingsEntriesTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, updatedAt, deleted, valueJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
    );
  }

  @override
  $SettingsEntriesTable createAlias(String alias) {
    return $SettingsEntriesTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String valueJson;
  const SettingRow({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.valueJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['value_json'] = Variable<String>(valueJson);
    return map;
  }

  SettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingsEntriesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      valueJson: Value(valueJson),
    );
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'valueJson': serializer.toJson<String>(valueJson),
    };
  }

  SettingRow copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? valueJson,
  }) => SettingRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    valueJson: valueJson ?? this.valueJson,
  );
  SettingRow copyWithCompanion(SettingsEntriesCompanion data) {
    return SettingRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('valueJson: $valueJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deleted, valueJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.valueJson == this.valueJson);
}

class SettingsEntriesCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> valueJson;
  final Value<int> rowid;
  const SettingsEntriesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsEntriesCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String valueJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       valueJson = Value(valueJson);
  static Insertable<SettingRow> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? valueJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (valueJson != null) 'value_json': valueJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? valueJson,
    Value<int>? rowid,
  }) {
    return SettingsEntriesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      valueJson: valueJson ?? this.valueJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntriesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('valueJson: $valueJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TerminalsTable extends Terminals
    with TableInfo<$TerminalsTable, Terminal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TerminalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<int> lastSeenAt = GeneratedColumn<int>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deleted,
    name,
    code,
    lastSeenAt,
    appVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'terminals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Terminal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Terminal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Terminal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_at'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      )!,
    );
  }

  @override
  $TerminalsTable createAlias(String alias) {
    return $TerminalsTable(attachedDatabase, alias);
  }
}

class Terminal extends DataClass implements Insertable<Terminal> {
  final String id;
  final int updatedAt;
  final bool deleted;
  final String name;
  final String code;
  final int lastSeenAt;
  final String appVersion;
  const Terminal({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    required this.name,
    required this.code,
    required this.lastSeenAt,
    required this.appVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    map['last_seen_at'] = Variable<int>(lastSeenAt);
    map['app_version'] = Variable<String>(appVersion);
    return map;
  }

  TerminalsCompanion toCompanion(bool nullToAbsent) {
    return TerminalsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      name: Value(name),
      code: Value(code),
      lastSeenAt: Value(lastSeenAt),
      appVersion: Value(appVersion),
    );
  }

  factory Terminal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Terminal(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      lastSeenAt: serializer.fromJson<int>(json['lastSeenAt']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'lastSeenAt': serializer.toJson<int>(lastSeenAt),
      'appVersion': serializer.toJson<String>(appVersion),
    };
  }

  Terminal copyWith({
    String? id,
    int? updatedAt,
    bool? deleted,
    String? name,
    String? code,
    int? lastSeenAt,
    String? appVersion,
  }) => Terminal(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    name: name ?? this.name,
    code: code ?? this.code,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    appVersion: appVersion ?? this.appVersion,
  );
  Terminal copyWithCompanion(TerminalsCompanion data) {
    return Terminal(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Terminal(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('appVersion: $appVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, deleted, name, code, lastSeenAt, appVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Terminal &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.name == this.name &&
          other.code == this.code &&
          other.lastSeenAt == this.lastSeenAt &&
          other.appVersion == this.appVersion);
}

class TerminalsCompanion extends UpdateCompanion<Terminal> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> code;
  final Value<int> lastSeenAt;
  final Value<String> appVersion;
  final Value<int> rowid;
  const TerminalsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TerminalsCompanion.insert({
    required String id,
    required int updatedAt,
    this.deleted = const Value.absent(),
    required String name,
    required String code,
    this.lastSeenAt = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       name = Value(name),
       code = Value(code);
  static Insertable<Terminal> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? code,
    Expression<int>? lastSeenAt,
    Expression<String>? appVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (appVersion != null) 'app_version': appVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TerminalsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? code,
    Value<int>? lastSeenAt,
    Value<String>? appVersion,
    Value<int>? rowid,
  }) {
    return TerminalsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      code: code ?? this.code,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      appVersion: appVersion ?? this.appVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<int>(lastSeenAt.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TerminalsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('appVersion: $appVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _collectionMeta = const VerificationMeta(
    'collection',
  );
  @override
  late final GeneratedColumn<String> collection = GeneratedColumn<String>(
    'collection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _docIdMeta = const VerificationMeta('docId');
  @override
  late final GeneratedColumn<String> docId = GeneratedColumn<String>(
    'doc_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    collection,
    docId,
    payload,
    createdAt,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('collection')) {
      context.handle(
        _collectionMeta,
        collection.isAcceptableOrUnknown(data['collection']!, _collectionMeta),
      );
    } else if (isInserting) {
      context.missing(_collectionMeta);
    }
    if (data.containsKey('doc_id')) {
      context.handle(
        _docIdMeta,
        docId.isAcceptableOrUnknown(data['doc_id']!, _docIdMeta),
      );
    } else if (isInserting) {
      context.missing(_docIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      collection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection'],
      )!,
      docId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final int seq;
  final String collection;
  final String docId;
  final String payload;
  final int createdAt;
  final int attempts;
  final String? lastError;
  const OutboxEntry({
    required this.seq,
    required this.collection,
    required this.docId,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['collection'] = Variable<String>(collection);
    map['doc_id'] = Variable<String>(docId);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<int>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      seq: Value(seq),
      collection: Value(collection),
      docId: Value(docId),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      seq: serializer.fromJson<int>(json['seq']),
      collection: serializer.fromJson<String>(json['collection']),
      docId: serializer.fromJson<String>(json['docId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'collection': serializer.toJson<String>(collection),
      'docId': serializer.toJson<String>(docId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<int>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxEntry copyWith({
    int? seq,
    String? collection,
    String? docId,
    String? payload,
    int? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => OutboxEntry(
    seq: seq ?? this.seq,
    collection: collection ?? this.collection,
    docId: docId ?? this.docId,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  OutboxEntry copyWithCompanion(OutboxCompanion data) {
    return OutboxEntry(
      seq: data.seq.present ? data.seq.value : this.seq,
      collection: data.collection.present
          ? data.collection.value
          : this.collection,
      docId: data.docId.present ? data.docId.value : this.docId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('seq: $seq, ')
          ..write('collection: $collection, ')
          ..write('docId: $docId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    collection,
    docId,
    payload,
    createdAt,
    attempts,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.seq == this.seq &&
          other.collection == this.collection &&
          other.docId == this.docId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class OutboxCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<int> seq;
  final Value<String> collection;
  final Value<String> docId;
  final Value<String> payload;
  final Value<int> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.collection = const Value.absent(),
    this.docId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String collection,
    required String docId,
    required String payload,
    required int createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : collection = Value(collection),
       docId = Value(docId),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<OutboxEntry> custom({
    Expression<int>? seq,
    Expression<String>? collection,
    Expression<String>? docId,
    Expression<String>? payload,
    Expression<int>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (collection != null) 'collection': collection,
      if (docId != null) 'doc_id': docId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? collection,
    Value<String>? docId,
    Value<String>? payload,
    Value<int>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
  }) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      collection: collection ?? this.collection,
      docId: docId ?? this.docId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (collection.present) {
      map['collection'] = Variable<String>(collection.value);
    }
    if (docId.present) {
      map['doc_id'] = Variable<String>(docId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('collection: $collection, ')
          ..write('docId: $docId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $LocalMetaTable extends LocalMeta
    with TableInfo<$LocalMetaTable, LocalMetaEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMetaEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalMetaEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMetaEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $LocalMetaTable createAlias(String alias) {
    return $LocalMetaTable(attachedDatabase, alias);
  }
}

class LocalMetaEntry extends DataClass implements Insertable<LocalMetaEntry> {
  final String key;
  final String value;
  const LocalMetaEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalMetaCompanion toCompanion(bool nullToAbsent) {
    return LocalMetaCompanion(key: Value(key), value: Value(value));
  }

  factory LocalMetaEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMetaEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  LocalMetaEntry copyWith({String? key, String? value}) =>
      LocalMetaEntry(key: key ?? this.key, value: value ?? this.value);
  LocalMetaEntry copyWithCompanion(LocalMetaCompanion data) {
    return LocalMetaEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMetaEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMetaEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class LocalMetaCompanion extends UpdateCompanion<LocalMetaEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LocalMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<LocalMetaEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return LocalMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ModifierGroupsTable modifierGroups = $ModifierGroupsTable(this);
  late final $TaxesTable taxes = $TaxesTable(this);
  late final $PaymentMethodsTable paymentMethods = $PaymentMethodsTable(this);
  late final $AreasTable areas = $AreasTable(this);
  late final $DiningTablesTable diningTables = $DiningTablesTable(this);
  late final $StaffTable staff = $StaffTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $RefundsTable refunds = $RefundsTable(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $CashMovementsTable cashMovements = $CashMovementsTable(this);
  late final $StockItemsTable stockItems = $StockItemsTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $SettingsEntriesTable settingsEntries = $SettingsEntriesTable(
    this,
  );
  late final $TerminalsTable terminals = $TerminalsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $LocalMetaTable localMeta = $LocalMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    products,
    modifierGroups,
    taxes,
    paymentMethods,
    areas,
    diningTables,
    staff,
    customers,
    orders,
    refunds,
    shifts,
    cashMovements,
    stockItems,
    recipes,
    stockMovements,
    auditLogs,
    settingsEntries,
    terminals,
    outbox,
    localMeta,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  required String name,
  Value<String> icon,
  Value<int> color,
  Value<int> sortOrder,
  Value<bool> active,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String> name,
  Value<String> icon,
  Value<int> color,
  Value<int> sortOrder,
  Value<bool> active,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          MenuCategory,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            MenuCategory,
            BaseReferences<_$AppDatabase, $CategoriesTable, MenuCategory>,
          ),
          MenuCategory,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, MenuCategory>(table),
                  BaseReferences<_$AppDatabase, $CategoriesTable, MenuCategory>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      MenuCategory,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        MenuCategory,
        BaseReferences<_$AppDatabase, $CategoriesTable, MenuCategory>,
      ),
      MenuCategory,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  required String categoryId,
  required String name,
  Value<String?> description,
  required int price,
  Value<String> sizesJson,
  Value<String> modifierGroupIdsJson,
  Value<bool> taxExempt,
  Value<String> icon,
  Value<int> color,
  Value<int> sortOrder,
  Value<bool> active,
  Value<bool> available,
  Value<bool> favourite,
  Value<String?> sku,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String> categoryId,
  Value<String> name,
  Value<String?> description,
  Value<int> price,
  Value<String> sizesJson,
  Value<String> modifierGroupIdsJson,
  Value<bool> taxExempt,
  Value<String> icon,
  Value<int> color,
  Value<int> sortOrder,
  Value<bool> active,
  Value<bool> available,
  Value<bool> favourite,
  Value<String?> sku,
  Value<int> rowid,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sizesJson => $composableBuilder(
    column: $table.sizesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modifierGroupIdsJson => $composableBuilder(
    column: $table.modifierGroupIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get taxExempt => $composableBuilder(
    column: $table.taxExempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get available => $composableBuilder(
    column: $table.available,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favourite => $composableBuilder(
    column: $table.favourite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sizesJson => $composableBuilder(
    column: $table.sizesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modifierGroupIdsJson => $composableBuilder(
    column: $table.modifierGroupIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get taxExempt => $composableBuilder(
    column: $table.taxExempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get available => $composableBuilder(
    column: $table.available,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favourite => $composableBuilder(
    column: $table.favourite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get sizesJson =>
      $composableBuilder(column: $table.sizesJson, builder: (column) => column);

  GeneratedColumn<String> get modifierGroupIdsJson => $composableBuilder(
    column: $table.modifierGroupIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get taxExempt =>
      $composableBuilder(column: $table.taxExempt, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<bool> get available =>
      $composableBuilder(column: $table.available, builder: (column) => column);

  GeneratedColumn<bool> get favourite =>
      $composableBuilder(column: $table.favourite, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
          Product,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<String> sizesJson = const Value.absent(),
                Value<String> modifierGroupIdsJson = const Value.absent(),
                Value<bool> taxExempt = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<bool> available = const Value.absent(),
                Value<bool> favourite = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                categoryId: categoryId,
                name: name,
                description: description,
                price: price,
                sizesJson: sizesJson,
                modifierGroupIdsJson: modifierGroupIdsJson,
                taxExempt: taxExempt,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                active: active,
                available: available,
                favourite: favourite,
                sku: sku,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String categoryId,
                required String name,
                Value<String?> description = const Value.absent(),
                required int price,
                Value<String> sizesJson = const Value.absent(),
                Value<String> modifierGroupIdsJson = const Value.absent(),
                Value<bool> taxExempt = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<bool> available = const Value.absent(),
                Value<bool> favourite = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                categoryId: categoryId,
                name: name,
                description: description,
                price: price,
                sizesJson: sizesJson,
                modifierGroupIdsJson: modifierGroupIdsJson,
                taxExempt: taxExempt,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                active: active,
                available: available,
                favourite: favourite,
                sku: sku,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTable, Product>(table),
                  BaseReferences<_$AppDatabase, $ProductsTable, Product>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
      Product,
      PrefetchHooks Function()
    >;
typedef $$ModifierGroupsTableCreateCompanionBuilder =
    ModifierGroupsCompanion Function({
      required String id,
      required int updatedAt,
      Value<bool> deleted,
      required String name,
      Value<int> minSelect,
      Value<int> maxSelect,
      Value<String> optionsJson,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$ModifierGroupsTableUpdateCompanionBuilder =
    ModifierGroupsCompanion Function({
      Value<String> id,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> name,
      Value<int> minSelect,
      Value<int> maxSelect,
      Value<String> optionsJson,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$ModifierGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $ModifierGroupsTable> {
  $$ModifierGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minSelect => $composableBuilder(
    column: $table.minSelect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxSelect => $composableBuilder(
    column: $table.maxSelect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModifierGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $ModifierGroupsTable> {
  $$ModifierGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minSelect => $composableBuilder(
    column: $table.minSelect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxSelect => $composableBuilder(
    column: $table.maxSelect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModifierGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModifierGroupsTable> {
  $$ModifierGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get minSelect =>
      $composableBuilder(column: $table.minSelect, builder: (column) => column);

  GeneratedColumn<int> get maxSelect =>
      $composableBuilder(column: $table.maxSelect, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ModifierGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModifierGroupsTable,
          ModifierGroup,
          $$ModifierGroupsTableFilterComposer,
          $$ModifierGroupsTableOrderingComposer,
          $$ModifierGroupsTableAnnotationComposer,
          $$ModifierGroupsTableCreateCompanionBuilder,
          $$ModifierGroupsTableUpdateCompanionBuilder,
          (
            ModifierGroup,
            BaseReferences<_$AppDatabase, $ModifierGroupsTable, ModifierGroup>,
          ),
          ModifierGroup,
          PrefetchHooks Function()
        > {
  $$ModifierGroupsTableTableManager(
    _$AppDatabase db,
    $ModifierGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModifierGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModifierGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModifierGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> minSelect = const Value.absent(),
                Value<int> maxSelect = const Value.absent(),
                Value<String> optionsJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModifierGroupsCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                minSelect: minSelect,
                maxSelect: maxSelect,
                optionsJson: optionsJson,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<int> minSelect = const Value.absent(),
                Value<int> maxSelect = const Value.absent(),
                Value<String> optionsJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModifierGroupsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                minSelect: minSelect,
                maxSelect: maxSelect,
                optionsJson: optionsJson,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ModifierGroupsTable, ModifierGroup>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ModifierGroupsTable,
                    ModifierGroup
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModifierGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModifierGroupsTable,
      ModifierGroup,
      $$ModifierGroupsTableFilterComposer,
      $$ModifierGroupsTableOrderingComposer,
      $$ModifierGroupsTableAnnotationComposer,
      $$ModifierGroupsTableCreateCompanionBuilder,
      $$ModifierGroupsTableUpdateCompanionBuilder,
      (
        ModifierGroup,
        BaseReferences<_$AppDatabase, $ModifierGroupsTable, ModifierGroup>,
      ),
      ModifierGroup,
      PrefetchHooks Function()
    >;
typedef $$TaxesTableCreateCompanionBuilder = TaxesCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  required String name,
  Value<bool> enabled,
  required int cashBp,
  required int cardOnlineBp,
  Value<bool> builtIn,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$TaxesTableUpdateCompanionBuilder = TaxesCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String> name,
  Value<bool> enabled,
  Value<int> cashBp,
  Value<int> cardOnlineBp,
  Value<bool> builtIn,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$TaxesTableFilterComposer extends Composer<_$AppDatabase, $TaxesTable> {
  $$TaxesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cashBp => $composableBuilder(
    column: $table.cashBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardOnlineBp => $composableBuilder(
    column: $table.cardOnlineBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaxesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaxesTable> {
  $$TaxesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cashBp => $composableBuilder(
    column: $table.cashBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardOnlineBp => $composableBuilder(
    column: $table.cardOnlineBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaxesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaxesTable> {
  $$TaxesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get cashBp =>
      $composableBuilder(column: $table.cashBp, builder: (column) => column);

  GeneratedColumn<int> get cardOnlineBp => $composableBuilder(
    column: $table.cardOnlineBp,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get builtIn =>
      $composableBuilder(column: $table.builtIn, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$TaxesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaxesTable,
          TaxRow,
          $$TaxesTableFilterComposer,
          $$TaxesTableOrderingComposer,
          $$TaxesTableAnnotationComposer,
          $$TaxesTableCreateCompanionBuilder,
          $$TaxesTableUpdateCompanionBuilder,
          (TaxRow, BaseReferences<_$AppDatabase, $TaxesTable, TaxRow>),
          TaxRow,
          PrefetchHooks Function()
        > {
  $$TaxesTableTableManager(_$AppDatabase db, $TaxesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaxesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaxesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaxesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> cashBp = const Value.absent(),
                Value<int> cardOnlineBp = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxesCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                enabled: enabled,
                cashBp: cashBp,
                cardOnlineBp: cardOnlineBp,
                builtIn: builtIn,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<bool> enabled = const Value.absent(),
                required int cashBp,
                required int cardOnlineBp,
                Value<bool> builtIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                enabled: enabled,
                cashBp: cashBp,
                cardOnlineBp: cardOnlineBp,
                builtIn: builtIn,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaxesTable, TaxRow>(table),
                  BaseReferences<_$AppDatabase, $TaxesTable, TaxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaxesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaxesTable,
      TaxRow,
      $$TaxesTableFilterComposer,
      $$TaxesTableOrderingComposer,
      $$TaxesTableAnnotationComposer,
      $$TaxesTableCreateCompanionBuilder,
      $$TaxesTableUpdateCompanionBuilder,
      (TaxRow, BaseReferences<_$AppDatabase, $TaxesTable, TaxRow>),
      TaxRow,
      PrefetchHooks Function()
    >;
typedef $$PaymentMethodsTableCreateCompanionBuilder =
    PaymentMethodsCompanion Function({
      required String id,
      required int updatedAt,
      Value<bool> deleted,
      required String name,
      required String rateGroup,
      Value<String> icon,
      Value<bool> opensDrawer,
      Value<bool> active,
      Value<bool> builtIn,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$PaymentMethodsTableUpdateCompanionBuilder =
    PaymentMethodsCompanion Function({
      Value<String> id,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> name,
      Value<String> rateGroup,
      Value<String> icon,
      Value<bool> opensDrawer,
      Value<bool> active,
      Value<bool> builtIn,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$PaymentMethodsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rateGroup => $composableBuilder(
    column: $table.rateGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get opensDrawer => $composableBuilder(
    column: $table.opensDrawer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentMethodsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateGroup => $composableBuilder(
    column: $table.rateGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get opensDrawer => $composableBuilder(
    column: $table.opensDrawer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentMethodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get rateGroup =>
      $composableBuilder(column: $table.rateGroup, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get opensDrawer => $composableBuilder(
    column: $table.opensDrawer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<bool> get builtIn =>
      $composableBuilder(column: $table.builtIn, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$PaymentMethodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentMethodsTable,
          PaymentMethod,
          $$PaymentMethodsTableFilterComposer,
          $$PaymentMethodsTableOrderingComposer,
          $$PaymentMethodsTableAnnotationComposer,
          $$PaymentMethodsTableCreateCompanionBuilder,
          $$PaymentMethodsTableUpdateCompanionBuilder,
          (
            PaymentMethod,
            BaseReferences<_$AppDatabase, $PaymentMethodsTable, PaymentMethod>,
          ),
          PaymentMethod,
          PrefetchHooks Function()
        > {
  $$PaymentMethodsTableTableManager(
    _$AppDatabase db,
    $PaymentMethodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentMethodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentMethodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentMethodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> rateGroup = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<bool> opensDrawer = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentMethodsCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                rateGroup: rateGroup,
                icon: icon,
                opensDrawer: opensDrawer,
                active: active,
                builtIn: builtIn,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                required String rateGroup,
                Value<String> icon = const Value.absent(),
                Value<bool> opensDrawer = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentMethodsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                rateGroup: rateGroup,
                icon: icon,
                opensDrawer: opensDrawer,
                active: active,
                builtIn: builtIn,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentMethodsTable, PaymentMethod>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PaymentMethodsTable,
                    PaymentMethod
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentMethodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentMethodsTable,
      PaymentMethod,
      $$PaymentMethodsTableFilterComposer,
      $$PaymentMethodsTableOrderingComposer,
      $$PaymentMethodsTableAnnotationComposer,
      $$PaymentMethodsTableCreateCompanionBuilder,
      $$PaymentMethodsTableUpdateCompanionBuilder,
      (
        PaymentMethod,
        BaseReferences<_$AppDatabase, $PaymentMethodsTable, PaymentMethod>,
      ),
      PaymentMethod,
      PrefetchHooks Function()
    >;
typedef $$AreasTableCreateCompanionBuilder = AreasCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  required String name,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$AreasTableUpdateCompanionBuilder = AreasCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String> name,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$AreasTableFilterComposer extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AreasTableOrderingComposer
    extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AreasTableAnnotationComposer
    extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$AreasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AreasTable,
          Area,
          $$AreasTableFilterComposer,
          $$AreasTableOrderingComposer,
          $$AreasTableAnnotationComposer,
          $$AreasTableCreateCompanionBuilder,
          $$AreasTableUpdateCompanionBuilder,
          (Area, BaseReferences<_$AppDatabase, $AreasTable, Area>),
          Area,
          PrefetchHooks Function()
        > {
  $$AreasTableTableManager(_$AppDatabase db, $AreasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AreasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AreasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AreasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AreasCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AreasCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AreasTable, Area>(table),
                  BaseReferences<_$AppDatabase, $AreasTable, Area>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AreasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AreasTable,
      Area,
      $$AreasTableFilterComposer,
      $$AreasTableOrderingComposer,
      $$AreasTableAnnotationComposer,
      $$AreasTableCreateCompanionBuilder,
      $$AreasTableUpdateCompanionBuilder,
      (Area, BaseReferences<_$AppDatabase, $AreasTable, Area>),
      Area,
      PrefetchHooks Function()
    >;
typedef $$DiningTablesTableCreateCompanionBuilder =
    DiningTablesCompanion Function({
      required String id,
      required int updatedAt,
      Value<bool> deleted,
      required String areaId,
      required String label,
      Value<int> seats,
      Value<int> sortOrder,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$DiningTablesTableUpdateCompanionBuilder =
    DiningTablesCompanion Function({
      Value<String> id,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> areaId,
      Value<String> label,
      Value<int> seats,
      Value<int> sortOrder,
      Value<bool> active,
      Value<int> rowid,
    });

class $$DiningTablesTableFilterComposer
    extends Composer<_$AppDatabase, $DiningTablesTable> {
  $$DiningTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seats => $composableBuilder(
    column: $table.seats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiningTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiningTablesTable> {
  $$DiningTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seats => $composableBuilder(
    column: $table.seats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiningTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiningTablesTable> {
  $$DiningTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get seats =>
      $composableBuilder(column: $table.seats, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$DiningTablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiningTablesTable,
          DiningTable,
          $$DiningTablesTableFilterComposer,
          $$DiningTablesTableOrderingComposer,
          $$DiningTablesTableAnnotationComposer,
          $$DiningTablesTableCreateCompanionBuilder,
          $$DiningTablesTableUpdateCompanionBuilder,
          (
            DiningTable,
            BaseReferences<_$AppDatabase, $DiningTablesTable, DiningTable>,
          ),
          DiningTable,
          PrefetchHooks Function()
        > {
  $$DiningTablesTableTableManager(_$AppDatabase db, $DiningTablesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiningTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiningTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiningTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> areaId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> seats = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiningTablesCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                areaId: areaId,
                label: label,
                seats: seats,
                sortOrder: sortOrder,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String areaId,
                required String label,
                Value<int> seats = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiningTablesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                areaId: areaId,
                label: label,
                seats: seats,
                sortOrder: sortOrder,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DiningTablesTable, DiningTable>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DiningTablesTable,
                    DiningTable
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiningTablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiningTablesTable,
      DiningTable,
      $$DiningTablesTableFilterComposer,
      $$DiningTablesTableOrderingComposer,
      $$DiningTablesTableAnnotationComposer,
      $$DiningTablesTableCreateCompanionBuilder,
      $$DiningTablesTableUpdateCompanionBuilder,
      (
        DiningTable,
        BaseReferences<_$AppDatabase, $DiningTablesTable, DiningTable>,
      ),
      DiningTable,
      PrefetchHooks Function()
    >;
typedef $$StaffTableCreateCompanionBuilder = StaffCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  required String name,
  required String role,
  required String pinHash,
  required String pinSalt,
  Value<bool> active,
  Value<int> color,
  Value<int> rowid,
});
typedef $$StaffTableUpdateCompanionBuilder = StaffCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String> name,
  Value<String> role,
  Value<String> pinHash,
  Value<String> pinSalt,
  Value<bool> active,
  Value<int> color,
  Value<int> rowid,
});

class $$StaffTableFilterComposer extends Composer<_$AppDatabase, $StaffTable> {
  $$StaffTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StaffTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffTable> {
  $$StaffTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StaffTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffTable> {
  $$StaffTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get pinSalt =>
      $composableBuilder(column: $table.pinSalt, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);
}

class $$StaffTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StaffTable,
          StaffMember,
          $$StaffTableFilterComposer,
          $$StaffTableOrderingComposer,
          $$StaffTableAnnotationComposer,
          $$StaffTableCreateCompanionBuilder,
          $$StaffTableUpdateCompanionBuilder,
          (
            StaffMember,
            BaseReferences<_$AppDatabase, $StaffTable, StaffMember>,
          ),
          StaffMember,
          PrefetchHooks Function()
        > {
  $$StaffTableTableManager(_$AppDatabase db, $StaffTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> pinHash = const Value.absent(),
                Value<String> pinSalt = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaffCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                role: role,
                pinHash: pinHash,
                pinSalt: pinSalt,
                active: active,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                required String role,
                required String pinHash,
                required String pinSalt,
                Value<bool> active = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaffCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                role: role,
                pinHash: pinHash,
                pinSalt: pinSalt,
                active: active,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StaffTable, StaffMember>(table),
                  BaseReferences<_$AppDatabase, $StaffTable, StaffMember>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StaffTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StaffTable,
      StaffMember,
      $$StaffTableFilterComposer,
      $$StaffTableOrderingComposer,
      $$StaffTableAnnotationComposer,
      $$StaffTableCreateCompanionBuilder,
      $$StaffTableUpdateCompanionBuilder,
      (StaffMember, BaseReferences<_$AppDatabase, $StaffTable, StaffMember>),
      StaffMember,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  required String name,
  Value<String> phone,
  Value<String?> address,
  Value<String?> notes,
  required int createdAt,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String> name,
  Value<String> phone,
  Value<String?> address,
  Value<String?> notes,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                phone: phone,
                address: address,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<String> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                phone: phone,
                address: address,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomersTable, Customer>(table),
                  BaseReferences<_$AppDatabase, $CustomersTable, Customer>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
    >;
typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  Value<String?> number,
  Value<int?> token,
  required String businessDate,
  required String orderType,
  required String status,
  Value<String?> tableId,
  Value<String?> tableLabel,
  Value<int?> guests,
  Value<String?> customerId,
  Value<String?> customerName,
  Value<String?> customerPhone,
  Value<String?> deliveryAddress,
  required String linesJson,
  Value<String?> orderDiscountJson,
  Value<String> chargesJson,
  Value<String> taxLinesJson,
  Value<String> paymentsJson,
  Value<bool> pricesIncludeTax,
  Value<int> itemsGross,
  Value<int> discountTotal,
  Value<int> chargesTotal,
  Value<int> taxTotal,
  Value<int> fbrFee,
  Value<int> rounding,
  Value<int> total,
  Value<int> netExTax,
  Value<int> refundedTotal,
  Value<String?> note,
  required String staffId,
  required String staffName,
  Value<String?> shiftId,
  required String deviceId,
  required String deviceCode,
  Value<bool> kotSent,
  Value<String> fiscalStatus,
  Value<String?> fiscalInvoiceNo,
  Value<String?> fiscalError,
  Value<int?> fiscalAt,
  required int createdAt,
  Value<int?> paidAt,
  Value<String?> voidReason,
  Value<String?> voidedBy,
  Value<int> rowid,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String?> number,
  Value<int?> token,
  Value<String> businessDate,
  Value<String> orderType,
  Value<String> status,
  Value<String?> tableId,
  Value<String?> tableLabel,
  Value<int?> guests,
  Value<String?> customerId,
  Value<String?> customerName,
  Value<String?> customerPhone,
  Value<String?> deliveryAddress,
  Value<String> linesJson,
  Value<String?> orderDiscountJson,
  Value<String> chargesJson,
  Value<String> taxLinesJson,
  Value<String> paymentsJson,
  Value<bool> pricesIncludeTax,
  Value<int> itemsGross,
  Value<int> discountTotal,
  Value<int> chargesTotal,
  Value<int> taxTotal,
  Value<int> fbrFee,
  Value<int> rounding,
  Value<int> total,
  Value<int> netExTax,
  Value<int> refundedTotal,
  Value<String?> note,
  Value<String> staffId,
  Value<String> staffName,
  Value<String?> shiftId,
  Value<String> deviceId,
  Value<String> deviceCode,
  Value<bool> kotSent,
  Value<String> fiscalStatus,
  Value<String?> fiscalInvoiceNo,
  Value<String?> fiscalError,
  Value<int?> fiscalAt,
  Value<int> createdAt,
  Value<int?> paidAt,
  Value<String?> voidReason,
  Value<String?> voidedBy,
  Value<int> rowid,
});

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderType => $composableBuilder(
    column: $table.orderType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableId => $composableBuilder(
    column: $table.tableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableLabel => $composableBuilder(
    column: $table.tableLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get guests => $composableBuilder(
    column: $table.guests,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryAddress => $composableBuilder(
    column: $table.deliveryAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linesJson => $composableBuilder(
    column: $table.linesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderDiscountJson => $composableBuilder(
    column: $table.orderDiscountJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chargesJson => $composableBuilder(
    column: $table.chargesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxLinesJson => $composableBuilder(
    column: $table.taxLinesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentsJson => $composableBuilder(
    column: $table.paymentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pricesIncludeTax => $composableBuilder(
    column: $table.pricesIncludeTax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemsGross => $composableBuilder(
    column: $table.itemsGross,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountTotal => $composableBuilder(
    column: $table.discountTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chargesTotal => $composableBuilder(
    column: $table.chargesTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxTotal => $composableBuilder(
    column: $table.taxTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fbrFee => $composableBuilder(
    column: $table.fbrFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rounding => $composableBuilder(
    column: $table.rounding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get netExTax => $composableBuilder(
    column: $table.netExTax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refundedTotal => $composableBuilder(
    column: $table.refundedTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffName => $composableBuilder(
    column: $table.staffName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get kotSent => $composableBuilder(
    column: $table.kotSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fiscalStatus => $composableBuilder(
    column: $table.fiscalStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fiscalInvoiceNo => $composableBuilder(
    column: $table.fiscalInvoiceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fiscalError => $composableBuilder(
    column: $table.fiscalError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fiscalAt => $composableBuilder(
    column: $table.fiscalAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidedBy => $composableBuilder(
    column: $table.voidedBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderType => $composableBuilder(
    column: $table.orderType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableId => $composableBuilder(
    column: $table.tableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableLabel => $composableBuilder(
    column: $table.tableLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get guests => $composableBuilder(
    column: $table.guests,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryAddress => $composableBuilder(
    column: $table.deliveryAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linesJson => $composableBuilder(
    column: $table.linesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderDiscountJson => $composableBuilder(
    column: $table.orderDiscountJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chargesJson => $composableBuilder(
    column: $table.chargesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxLinesJson => $composableBuilder(
    column: $table.taxLinesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentsJson => $composableBuilder(
    column: $table.paymentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pricesIncludeTax => $composableBuilder(
    column: $table.pricesIncludeTax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemsGross => $composableBuilder(
    column: $table.itemsGross,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountTotal => $composableBuilder(
    column: $table.discountTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chargesTotal => $composableBuilder(
    column: $table.chargesTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxTotal => $composableBuilder(
    column: $table.taxTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fbrFee => $composableBuilder(
    column: $table.fbrFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rounding => $composableBuilder(
    column: $table.rounding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netExTax => $composableBuilder(
    column: $table.netExTax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refundedTotal => $composableBuilder(
    column: $table.refundedTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffName => $composableBuilder(
    column: $table.staffName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get kotSent => $composableBuilder(
    column: $table.kotSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fiscalStatus => $composableBuilder(
    column: $table.fiscalStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fiscalInvoiceNo => $composableBuilder(
    column: $table.fiscalInvoiceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fiscalError => $composableBuilder(
    column: $table.fiscalError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fiscalAt => $composableBuilder(
    column: $table.fiscalAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidedBy => $composableBuilder(
    column: $table.voidedBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderType =>
      $composableBuilder(column: $table.orderType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get tableId =>
      $composableBuilder(column: $table.tableId, builder: (column) => column);

  GeneratedColumn<String> get tableLabel => $composableBuilder(
    column: $table.tableLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get guests =>
      $composableBuilder(column: $table.guests, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryAddress => $composableBuilder(
    column: $table.deliveryAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linesJson =>
      $composableBuilder(column: $table.linesJson, builder: (column) => column);

  GeneratedColumn<String> get orderDiscountJson => $composableBuilder(
    column: $table.orderDiscountJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chargesJson => $composableBuilder(
    column: $table.chargesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taxLinesJson => $composableBuilder(
    column: $table.taxLinesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentsJson => $composableBuilder(
    column: $table.paymentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pricesIncludeTax => $composableBuilder(
    column: $table.pricesIncludeTax,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemsGross => $composableBuilder(
    column: $table.itemsGross,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountTotal => $composableBuilder(
    column: $table.discountTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chargesTotal => $composableBuilder(
    column: $table.chargesTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxTotal =>
      $composableBuilder(column: $table.taxTotal, builder: (column) => column);

  GeneratedColumn<int> get fbrFee =>
      $composableBuilder(column: $table.fbrFee, builder: (column) => column);

  GeneratedColumn<int> get rounding =>
      $composableBuilder(column: $table.rounding, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get netExTax =>
      $composableBuilder(column: $table.netExTax, builder: (column) => column);

  GeneratedColumn<int> get refundedTotal => $composableBuilder(
    column: $table.refundedTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get staffName =>
      $composableBuilder(column: $table.staffName, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get kotSent =>
      $composableBuilder(column: $table.kotSent, builder: (column) => column);

  GeneratedColumn<String> get fiscalStatus => $composableBuilder(
    column: $table.fiscalStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fiscalInvoiceNo => $composableBuilder(
    column: $table.fiscalInvoiceNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fiscalError => $composableBuilder(
    column: $table.fiscalError,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fiscalAt =>
      $composableBuilder(column: $table.fiscalAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voidedBy =>
      $composableBuilder(column: $table.voidedBy, builder: (column) => column);
}

class $$OrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdersTable,
          Order,
          $$OrdersTableFilterComposer,
          $$OrdersTableOrderingComposer,
          $$OrdersTableAnnotationComposer,
          $$OrdersTableCreateCompanionBuilder,
          $$OrdersTableUpdateCompanionBuilder,
          (Order, BaseReferences<_$AppDatabase, $OrdersTable, Order>),
          Order,
          PrefetchHooks Function()
        > {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> number = const Value.absent(),
                Value<int?> token = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<String> orderType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> tableId = const Value.absent(),
                Value<String?> tableLabel = const Value.absent(),
                Value<int?> guests = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String?> customerPhone = const Value.absent(),
                Value<String?> deliveryAddress = const Value.absent(),
                Value<String> linesJson = const Value.absent(),
                Value<String?> orderDiscountJson = const Value.absent(),
                Value<String> chargesJson = const Value.absent(),
                Value<String> taxLinesJson = const Value.absent(),
                Value<String> paymentsJson = const Value.absent(),
                Value<bool> pricesIncludeTax = const Value.absent(),
                Value<int> itemsGross = const Value.absent(),
                Value<int> discountTotal = const Value.absent(),
                Value<int> chargesTotal = const Value.absent(),
                Value<int> taxTotal = const Value.absent(),
                Value<int> fbrFee = const Value.absent(),
                Value<int> rounding = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> netExTax = const Value.absent(),
                Value<int> refundedTotal = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> staffId = const Value.absent(),
                Value<String> staffName = const Value.absent(),
                Value<String?> shiftId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> deviceCode = const Value.absent(),
                Value<bool> kotSent = const Value.absent(),
                Value<String> fiscalStatus = const Value.absent(),
                Value<String?> fiscalInvoiceNo = const Value.absent(),
                Value<String?> fiscalError = const Value.absent(),
                Value<int?> fiscalAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> paidAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<String?> voidedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                number: number,
                token: token,
                businessDate: businessDate,
                orderType: orderType,
                status: status,
                tableId: tableId,
                tableLabel: tableLabel,
                guests: guests,
                customerId: customerId,
                customerName: customerName,
                customerPhone: customerPhone,
                deliveryAddress: deliveryAddress,
                linesJson: linesJson,
                orderDiscountJson: orderDiscountJson,
                chargesJson: chargesJson,
                taxLinesJson: taxLinesJson,
                paymentsJson: paymentsJson,
                pricesIncludeTax: pricesIncludeTax,
                itemsGross: itemsGross,
                discountTotal: discountTotal,
                chargesTotal: chargesTotal,
                taxTotal: taxTotal,
                fbrFee: fbrFee,
                rounding: rounding,
                total: total,
                netExTax: netExTax,
                refundedTotal: refundedTotal,
                note: note,
                staffId: staffId,
                staffName: staffName,
                shiftId: shiftId,
                deviceId: deviceId,
                deviceCode: deviceCode,
                kotSent: kotSent,
                fiscalStatus: fiscalStatus,
                fiscalInvoiceNo: fiscalInvoiceNo,
                fiscalError: fiscalError,
                fiscalAt: fiscalAt,
                createdAt: createdAt,
                paidAt: paidAt,
                voidReason: voidReason,
                voidedBy: voidedBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                Value<String?> number = const Value.absent(),
                Value<int?> token = const Value.absent(),
                required String businessDate,
                required String orderType,
                required String status,
                Value<String?> tableId = const Value.absent(),
                Value<String?> tableLabel = const Value.absent(),
                Value<int?> guests = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String?> customerPhone = const Value.absent(),
                Value<String?> deliveryAddress = const Value.absent(),
                required String linesJson,
                Value<String?> orderDiscountJson = const Value.absent(),
                Value<String> chargesJson = const Value.absent(),
                Value<String> taxLinesJson = const Value.absent(),
                Value<String> paymentsJson = const Value.absent(),
                Value<bool> pricesIncludeTax = const Value.absent(),
                Value<int> itemsGross = const Value.absent(),
                Value<int> discountTotal = const Value.absent(),
                Value<int> chargesTotal = const Value.absent(),
                Value<int> taxTotal = const Value.absent(),
                Value<int> fbrFee = const Value.absent(),
                Value<int> rounding = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> netExTax = const Value.absent(),
                Value<int> refundedTotal = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required String staffId,
                required String staffName,
                Value<String?> shiftId = const Value.absent(),
                required String deviceId,
                required String deviceCode,
                Value<bool> kotSent = const Value.absent(),
                Value<String> fiscalStatus = const Value.absent(),
                Value<String?> fiscalInvoiceNo = const Value.absent(),
                Value<String?> fiscalError = const Value.absent(),
                Value<int?> fiscalAt = const Value.absent(),
                required int createdAt,
                Value<int?> paidAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<String?> voidedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                number: number,
                token: token,
                businessDate: businessDate,
                orderType: orderType,
                status: status,
                tableId: tableId,
                tableLabel: tableLabel,
                guests: guests,
                customerId: customerId,
                customerName: customerName,
                customerPhone: customerPhone,
                deliveryAddress: deliveryAddress,
                linesJson: linesJson,
                orderDiscountJson: orderDiscountJson,
                chargesJson: chargesJson,
                taxLinesJson: taxLinesJson,
                paymentsJson: paymentsJson,
                pricesIncludeTax: pricesIncludeTax,
                itemsGross: itemsGross,
                discountTotal: discountTotal,
                chargesTotal: chargesTotal,
                taxTotal: taxTotal,
                fbrFee: fbrFee,
                rounding: rounding,
                total: total,
                netExTax: netExTax,
                refundedTotal: refundedTotal,
                note: note,
                staffId: staffId,
                staffName: staffName,
                shiftId: shiftId,
                deviceId: deviceId,
                deviceCode: deviceCode,
                kotSent: kotSent,
                fiscalStatus: fiscalStatus,
                fiscalInvoiceNo: fiscalInvoiceNo,
                fiscalError: fiscalError,
                fiscalAt: fiscalAt,
                createdAt: createdAt,
                paidAt: paidAt,
                voidReason: voidReason,
                voidedBy: voidedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OrdersTable, Order>(table),
                  BaseReferences<_$AppDatabase, $OrdersTable, Order>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdersTable,
      Order,
      $$OrdersTableFilterComposer,
      $$OrdersTableOrderingComposer,
      $$OrdersTableAnnotationComposer,
      $$OrdersTableCreateCompanionBuilder,
      $$OrdersTableUpdateCompanionBuilder,
      (Order, BaseReferences<_$AppDatabase, $OrdersTable, Order>),
      Order,
      PrefetchHooks Function()
    >;
typedef $$RefundsTableCreateCompanionBuilder = RefundsCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  required String orderId,
  required String orderNumber,
  required String linesJson,
  required int amount,
  required int taxAmount,
  required String methodId,
  required String methodName,
  required String rateGroup,
  required String reason,
  Value<bool> restock,
  required String staffId,
  required String staffName,
  Value<String?> approvedBy,
  Value<String?> shiftId,
  required String deviceId,
  required String businessDate,
  required int createdAt,
  Value<int> rowid,
});
typedef $$RefundsTableUpdateCompanionBuilder = RefundsCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String> orderId,
  Value<String> orderNumber,
  Value<String> linesJson,
  Value<int> amount,
  Value<int> taxAmount,
  Value<String> methodId,
  Value<String> methodName,
  Value<String> rateGroup,
  Value<String> reason,
  Value<bool> restock,
  Value<String> staffId,
  Value<String> staffName,
  Value<String?> approvedBy,
  Value<String?> shiftId,
  Value<String> deviceId,
  Value<String> businessDate,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$RefundsTableFilterComposer
    extends Composer<_$AppDatabase, $RefundsTable> {
  $$RefundsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linesJson => $composableBuilder(
    column: $table.linesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get methodId => $composableBuilder(
    column: $table.methodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get methodName => $composableBuilder(
    column: $table.methodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rateGroup => $composableBuilder(
    column: $table.rateGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get restock => $composableBuilder(
    column: $table.restock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffName => $composableBuilder(
    column: $table.staffName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approvedBy => $composableBuilder(
    column: $table.approvedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RefundsTableOrderingComposer
    extends Composer<_$AppDatabase, $RefundsTable> {
  $$RefundsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linesJson => $composableBuilder(
    column: $table.linesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methodId => $composableBuilder(
    column: $table.methodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methodName => $composableBuilder(
    column: $table.methodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateGroup => $composableBuilder(
    column: $table.rateGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get restock => $composableBuilder(
    column: $table.restock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffName => $composableBuilder(
    column: $table.staffName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approvedBy => $composableBuilder(
    column: $table.approvedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RefundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RefundsTable> {
  $$RefundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linesJson =>
      $composableBuilder(column: $table.linesJson, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<String> get methodId =>
      $composableBuilder(column: $table.methodId, builder: (column) => column);

  GeneratedColumn<String> get methodName => $composableBuilder(
    column: $table.methodName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rateGroup =>
      $composableBuilder(column: $table.rateGroup, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<bool> get restock =>
      $composableBuilder(column: $table.restock, builder: (column) => column);

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get staffName =>
      $composableBuilder(column: $table.staffName, builder: (column) => column);

  GeneratedColumn<String> get approvedBy => $composableBuilder(
    column: $table.approvedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RefundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RefundsTable,
          Refund,
          $$RefundsTableFilterComposer,
          $$RefundsTableOrderingComposer,
          $$RefundsTableAnnotationComposer,
          $$RefundsTableCreateCompanionBuilder,
          $$RefundsTableUpdateCompanionBuilder,
          (Refund, BaseReferences<_$AppDatabase, $RefundsTable, Refund>),
          Refund,
          PrefetchHooks Function()
        > {
  $$RefundsTableTableManager(_$AppDatabase db, $RefundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RefundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RefundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RefundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> orderNumber = const Value.absent(),
                Value<String> linesJson = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> taxAmount = const Value.absent(),
                Value<String> methodId = const Value.absent(),
                Value<String> methodName = const Value.absent(),
                Value<String> rateGroup = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<bool> restock = const Value.absent(),
                Value<String> staffId = const Value.absent(),
                Value<String> staffName = const Value.absent(),
                Value<String?> approvedBy = const Value.absent(),
                Value<String?> shiftId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RefundsCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                orderId: orderId,
                orderNumber: orderNumber,
                linesJson: linesJson,
                amount: amount,
                taxAmount: taxAmount,
                methodId: methodId,
                methodName: methodName,
                rateGroup: rateGroup,
                reason: reason,
                restock: restock,
                staffId: staffId,
                staffName: staffName,
                approvedBy: approvedBy,
                shiftId: shiftId,
                deviceId: deviceId,
                businessDate: businessDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String orderId,
                required String orderNumber,
                required String linesJson,
                required int amount,
                required int taxAmount,
                required String methodId,
                required String methodName,
                required String rateGroup,
                required String reason,
                Value<bool> restock = const Value.absent(),
                required String staffId,
                required String staffName,
                Value<String?> approvedBy = const Value.absent(),
                Value<String?> shiftId = const Value.absent(),
                required String deviceId,
                required String businessDate,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RefundsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                orderId: orderId,
                orderNumber: orderNumber,
                linesJson: linesJson,
                amount: amount,
                taxAmount: taxAmount,
                methodId: methodId,
                methodName: methodName,
                rateGroup: rateGroup,
                reason: reason,
                restock: restock,
                staffId: staffId,
                staffName: staffName,
                approvedBy: approvedBy,
                shiftId: shiftId,
                deviceId: deviceId,
                businessDate: businessDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RefundsTable, Refund>(table),
                  BaseReferences<_$AppDatabase, $RefundsTable, Refund>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RefundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RefundsTable,
      Refund,
      $$RefundsTableFilterComposer,
      $$RefundsTableOrderingComposer,
      $$RefundsTableAnnotationComposer,
      $$RefundsTableCreateCompanionBuilder,
      $$RefundsTableUpdateCompanionBuilder,
      (Refund, BaseReferences<_$AppDatabase, $RefundsTable, Refund>),
      Refund,
      PrefetchHooks Function()
    >;
typedef $$ShiftsTableCreateCompanionBuilder = ShiftsCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  required String deviceId,
  required String deviceCode,
  required String status,
  required String openedById,
  required String openedByName,
  required int openedAt,
  required int openingFloat,
  Value<String?> closedById,
  Value<String?> closedByName,
  Value<int?> closedAt,
  Value<int?> countedCash,
  Value<int?> expectedCash,
  Value<String?> note,
  Value<String?> summaryJson,
  Value<int> rowid,
});
typedef $$ShiftsTableUpdateCompanionBuilder = ShiftsCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String> deviceId,
  Value<String> deviceCode,
  Value<String> status,
  Value<String> openedById,
  Value<String> openedByName,
  Value<int> openedAt,
  Value<int> openingFloat,
  Value<String?> closedById,
  Value<String?> closedByName,
  Value<int?> closedAt,
  Value<int?> countedCash,
  Value<int?> expectedCash,
  Value<String?> note,
  Value<String?> summaryJson,
  Value<int> rowid,
});

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openedById => $composableBuilder(
    column: $table.openedById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openedByName => $composableBuilder(
    column: $table.openedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingFloat => $composableBuilder(
    column: $table.openingFloat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedByName => $composableBuilder(
    column: $table.closedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countedCash => $composableBuilder(
    column: $table.countedCash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedCash => $composableBuilder(
    column: $table.expectedCash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openedById => $composableBuilder(
    column: $table.openedById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openedByName => $composableBuilder(
    column: $table.openedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingFloat => $composableBuilder(
    column: $table.openingFloat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedByName => $composableBuilder(
    column: $table.closedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countedCash => $composableBuilder(
    column: $table.countedCash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedCash => $composableBuilder(
    column: $table.expectedCash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get openedById => $composableBuilder(
    column: $table.openedById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openedByName => $composableBuilder(
    column: $table.openedByName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<int> get openingFloat => $composableBuilder(
    column: $table.openingFloat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closedByName => $composableBuilder(
    column: $table.closedByName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<int> get countedCash => $composableBuilder(
    column: $table.countedCash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedCash => $composableBuilder(
    column: $table.expectedCash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => column,
  );
}

class $$ShiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTable,
          Shift,
          $$ShiftsTableFilterComposer,
          $$ShiftsTableOrderingComposer,
          $$ShiftsTableAnnotationComposer,
          $$ShiftsTableCreateCompanionBuilder,
          $$ShiftsTableUpdateCompanionBuilder,
          (Shift, BaseReferences<_$AppDatabase, $ShiftsTable, Shift>),
          Shift,
          PrefetchHooks Function()
        > {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> deviceCode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> openedById = const Value.absent(),
                Value<String> openedByName = const Value.absent(),
                Value<int> openedAt = const Value.absent(),
                Value<int> openingFloat = const Value.absent(),
                Value<String?> closedById = const Value.absent(),
                Value<String?> closedByName = const Value.absent(),
                Value<int?> closedAt = const Value.absent(),
                Value<int?> countedCash = const Value.absent(),
                Value<int?> expectedCash = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> summaryJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                deviceId: deviceId,
                deviceCode: deviceCode,
                status: status,
                openedById: openedById,
                openedByName: openedByName,
                openedAt: openedAt,
                openingFloat: openingFloat,
                closedById: closedById,
                closedByName: closedByName,
                closedAt: closedAt,
                countedCash: countedCash,
                expectedCash: expectedCash,
                note: note,
                summaryJson: summaryJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String deviceId,
                required String deviceCode,
                required String status,
                required String openedById,
                required String openedByName,
                required int openedAt,
                required int openingFloat,
                Value<String?> closedById = const Value.absent(),
                Value<String?> closedByName = const Value.absent(),
                Value<int?> closedAt = const Value.absent(),
                Value<int?> countedCash = const Value.absent(),
                Value<int?> expectedCash = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> summaryJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                deviceId: deviceId,
                deviceCode: deviceCode,
                status: status,
                openedById: openedById,
                openedByName: openedByName,
                openedAt: openedAt,
                openingFloat: openingFloat,
                closedById: closedById,
                closedByName: closedByName,
                closedAt: closedAt,
                countedCash: countedCash,
                expectedCash: expectedCash,
                note: note,
                summaryJson: summaryJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShiftsTable, Shift>(table),
                  BaseReferences<_$AppDatabase, $ShiftsTable, Shift>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTable,
      Shift,
      $$ShiftsTableFilterComposer,
      $$ShiftsTableOrderingComposer,
      $$ShiftsTableAnnotationComposer,
      $$ShiftsTableCreateCompanionBuilder,
      $$ShiftsTableUpdateCompanionBuilder,
      (Shift, BaseReferences<_$AppDatabase, $ShiftsTable, Shift>),
      Shift,
      PrefetchHooks Function()
    >;
typedef $$CashMovementsTableCreateCompanionBuilder =
    CashMovementsCompanion Function({
      required String id,
      required int updatedAt,
      Value<bool> deleted,
      required String shiftId,
      required String type,
      required int amount,
      required String reason,
      required String staffId,
      required String staffName,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$CashMovementsTableUpdateCompanionBuilder =
    CashMovementsCompanion Function({
      Value<String> id,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> shiftId,
      Value<String> type,
      Value<int> amount,
      Value<String> reason,
      Value<String> staffId,
      Value<String> staffName,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$CashMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffName => $composableBuilder(
    column: $table.staffName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffName => $composableBuilder(
    column: $table.staffName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get staffName =>
      $composableBuilder(column: $table.staffName, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CashMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashMovementsTable,
          CashMovement,
          $$CashMovementsTableFilterComposer,
          $$CashMovementsTableOrderingComposer,
          $$CashMovementsTableAnnotationComposer,
          $$CashMovementsTableCreateCompanionBuilder,
          $$CashMovementsTableUpdateCompanionBuilder,
          (
            CashMovement,
            BaseReferences<_$AppDatabase, $CashMovementsTable, CashMovement>,
          ),
          CashMovement,
          PrefetchHooks Function()
        > {
  $$CashMovementsTableTableManager(_$AppDatabase db, $CashMovementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> shiftId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> staffId = const Value.absent(),
                Value<String> staffName = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashMovementsCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                shiftId: shiftId,
                type: type,
                amount: amount,
                reason: reason,
                staffId: staffId,
                staffName: staffName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String shiftId,
                required String type,
                required int amount,
                required String reason,
                required String staffId,
                required String staffName,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CashMovementsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                shiftId: shiftId,
                type: type,
                amount: amount,
                reason: reason,
                staffId: staffId,
                staffName: staffName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashMovementsTable, CashMovement>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CashMovementsTable,
                    CashMovement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashMovementsTable,
      CashMovement,
      $$CashMovementsTableFilterComposer,
      $$CashMovementsTableOrderingComposer,
      $$CashMovementsTableAnnotationComposer,
      $$CashMovementsTableCreateCompanionBuilder,
      $$CashMovementsTableUpdateCompanionBuilder,
      (
        CashMovement,
        BaseReferences<_$AppDatabase, $CashMovementsTable, CashMovement>,
      ),
      CashMovement,
      PrefetchHooks Function()
    >;
typedef $$StockItemsTableCreateCompanionBuilder = StockItemsCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  required String name,
  Value<String> groupName,
  required String unit,
  Value<double> reorderLevel,
  Value<double> parLevel,
  Value<int> costPerUnit,
  Value<String> icon,
  Value<bool> active,
  Value<int> rowid,
});
typedef $$StockItemsTableUpdateCompanionBuilder = StockItemsCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String> name,
  Value<String> groupName,
  Value<String> unit,
  Value<double> reorderLevel,
  Value<double> parLevel,
  Value<int> costPerUnit,
  Value<String> icon,
  Value<bool> active,
  Value<int> rowid,
});

class $$StockItemsTableFilterComposer
    extends Composer<_$AppDatabase, $StockItemsTable> {
  $$StockItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get parLevel => $composableBuilder(
    column: $table.parLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockItemsTable> {
  $$StockItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get parLevel => $composableBuilder(
    column: $table.parLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockItemsTable> {
  $$StockItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get parLevel =>
      $composableBuilder(column: $table.parLevel, builder: (column) => column);

  GeneratedColumn<int> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$StockItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockItemsTable,
          StockItem,
          $$StockItemsTableFilterComposer,
          $$StockItemsTableOrderingComposer,
          $$StockItemsTableAnnotationComposer,
          $$StockItemsTableCreateCompanionBuilder,
          $$StockItemsTableUpdateCompanionBuilder,
          (
            StockItem,
            BaseReferences<_$AppDatabase, $StockItemsTable, StockItem>,
          ),
          StockItem,
          PrefetchHooks Function()
        > {
  $$StockItemsTableTableManager(_$AppDatabase db, $StockItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> groupName = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> reorderLevel = const Value.absent(),
                Value<double> parLevel = const Value.absent(),
                Value<int> costPerUnit = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockItemsCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                groupName: groupName,
                unit: unit,
                reorderLevel: reorderLevel,
                parLevel: parLevel,
                costPerUnit: costPerUnit,
                icon: icon,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                Value<String> groupName = const Value.absent(),
                required String unit,
                Value<double> reorderLevel = const Value.absent(),
                Value<double> parLevel = const Value.absent(),
                Value<int> costPerUnit = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockItemsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                groupName: groupName,
                unit: unit,
                reorderLevel: reorderLevel,
                parLevel: parLevel,
                costPerUnit: costPerUnit,
                icon: icon,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StockItemsTable, StockItem>(table),
                  BaseReferences<_$AppDatabase, $StockItemsTable, StockItem>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockItemsTable,
      StockItem,
      $$StockItemsTableFilterComposer,
      $$StockItemsTableOrderingComposer,
      $$StockItemsTableAnnotationComposer,
      $$StockItemsTableCreateCompanionBuilder,
      $$StockItemsTableUpdateCompanionBuilder,
      (StockItem, BaseReferences<_$AppDatabase, $StockItemsTable, StockItem>),
      StockItem,
      PrefetchHooks Function()
    >;
typedef $$RecipesTableCreateCompanionBuilder = RecipesCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  required String productId,
  Value<String> sizeCode,
  Value<String> itemsJson,
  Value<int> rowid,
});
typedef $$RecipesTableUpdateCompanionBuilder = RecipesCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String> productId,
  Value<String> sizeCode,
  Value<String> itemsJson,
  Value<int> rowid,
});

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sizeCode => $composableBuilder(
    column: $table.sizeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sizeCode => $composableBuilder(
    column: $table.sizeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get sizeCode =>
      $composableBuilder(column: $table.sizeCode, builder: (column) => column);

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          Recipe,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (Recipe, BaseReferences<_$AppDatabase, $RecipesTable, Recipe>),
          Recipe,
          PrefetchHooks Function()
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> sizeCode = const Value.absent(),
                Value<String> itemsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                productId: productId,
                sizeCode: sizeCode,
                itemsJson: itemsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String productId,
                Value<String> sizeCode = const Value.absent(),
                Value<String> itemsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                productId: productId,
                sizeCode: sizeCode,
                itemsJson: itemsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecipesTable, Recipe>(table),
                  BaseReferences<_$AppDatabase, $RecipesTable, Recipe>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      Recipe,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (Recipe, BaseReferences<_$AppDatabase, $RecipesTable, Recipe>),
      Recipe,
      PrefetchHooks Function()
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      required String id,
      required int updatedAt,
      Value<bool> deleted,
      required String stockItemId,
      required double qty,
      required String type,
      Value<String?> refId,
      Value<String?> note,
      Value<int?> unitCost,
      Value<String?> staffId,
      Value<String?> staffName,
      Value<String?> deviceId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<String> id,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> stockItemId,
      Value<double> qty,
      Value<String> type,
      Value<String?> refId,
      Value<String?> note,
      Value<int?> unitCost,
      Value<String?> staffId,
      Value<String?> staffName,
      Value<String?> deviceId,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockItemId => $composableBuilder(
    column: $table.stockItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffName => $composableBuilder(
    column: $table.staffName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockItemId => $composableBuilder(
    column: $table.stockItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffName => $composableBuilder(
    column: $table.staffName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get stockItemId => $composableBuilder(
    column: $table.stockItemId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get staffName =>
      $composableBuilder(column: $table.staffName, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTable,
          StockMovement,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (
            StockMovement,
            BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>,
          ),
          StockMovement,
          PrefetchHooks Function()
        > {
  $$StockMovementsTableTableManager(
    _$AppDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> stockItemId = const Value.absent(),
                Value<double> qty = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> refId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> unitCost = const Value.absent(),
                Value<String?> staffId = const Value.absent(),
                Value<String?> staffName = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                stockItemId: stockItemId,
                qty: qty,
                type: type,
                refId: refId,
                note: note,
                unitCost: unitCost,
                staffId: staffId,
                staffName: staffName,
                deviceId: deviceId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String stockItemId,
                required double qty,
                required String type,
                Value<String?> refId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> unitCost = const Value.absent(),
                Value<String?> staffId = const Value.absent(),
                Value<String?> staffName = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                stockItemId: stockItemId,
                qty: qty,
                type: type,
                refId: refId,
                note: note,
                unitCost: unitCost,
                staffId: staffId,
                staffName: staffName,
                deviceId: deviceId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StockMovementsTable, StockMovement>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StockMovementsTable,
                    StockMovement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTable,
      StockMovement,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (
        StockMovement,
        BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>,
      ),
      StockMovement,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  required String action,
  required String staffId,
  required String staffName,
  Value<String?> approvedById,
  Value<String?> approvedByName,
  Value<String> detailsJson,
  Value<String?> deviceId,
  required int createdAt,
  Value<int> rowid,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String> action,
  Value<String> staffId,
  Value<String> staffName,
  Value<String?> approvedById,
  Value<String?> approvedByName,
  Value<String> detailsJson,
  Value<String?> deviceId,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffName => $composableBuilder(
    column: $table.staffName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approvedById => $composableBuilder(
    column: $table.approvedById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approvedByName => $composableBuilder(
    column: $table.approvedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffName => $composableBuilder(
    column: $table.staffName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approvedById => $composableBuilder(
    column: $table.approvedById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approvedByName => $composableBuilder(
    column: $table.approvedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get staffName =>
      $composableBuilder(column: $table.staffName, builder: (column) => column);

  GeneratedColumn<String> get approvedById => $composableBuilder(
    column: $table.approvedById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get approvedByName => $composableBuilder(
    column: $table.approvedByName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> staffId = const Value.absent(),
                Value<String> staffName = const Value.absent(),
                Value<String?> approvedById = const Value.absent(),
                Value<String?> approvedByName = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                action: action,
                staffId: staffId,
                staffName: staffName,
                approvedById: approvedById,
                approvedByName: approvedByName,
                detailsJson: detailsJson,
                deviceId: deviceId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String action,
                required String staffId,
                required String staffName,
                Value<String?> approvedById = const Value.absent(),
                Value<String?> approvedByName = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                action: action,
                staffId: staffId,
                staffName: staffName,
                approvedById: approvedById,
                approvedByName: approvedByName,
                detailsJson: detailsJson,
                deviceId: deviceId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditLogsTable, AuditLog>(table),
                  BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$SettingsEntriesTableCreateCompanionBuilder =
    SettingsEntriesCompanion Function({
      required String id,
      required int updatedAt,
      Value<bool> deleted,
      required String valueJson,
      Value<int> rowid,
    });
typedef $$SettingsEntriesTableUpdateCompanionBuilder =
    SettingsEntriesCompanion Function({
      Value<String> id,
      Value<int> updatedAt,
      Value<bool> deleted,
      Value<String> valueJson,
      Value<int> rowid,
    });

class $$SettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);
}

class $$SettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsEntriesTable,
          SettingRow,
          $$SettingsEntriesTableFilterComposer,
          $$SettingsEntriesTableOrderingComposer,
          $$SettingsEntriesTableAnnotationComposer,
          $$SettingsEntriesTableCreateCompanionBuilder,
          $$SettingsEntriesTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsEntriesTableTableManager(
    _$AppDatabase db,
    $SettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsEntriesCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                valueJson: valueJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String valueJson,
                Value<int> rowid = const Value.absent(),
              }) => SettingsEntriesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                valueJson: valueJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsEntriesTable, SettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingsEntriesTable,
                    SettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsEntriesTable,
      SettingRow,
      $$SettingsEntriesTableFilterComposer,
      $$SettingsEntriesTableOrderingComposer,
      $$SettingsEntriesTableAnnotationComposer,
      $$SettingsEntriesTableCreateCompanionBuilder,
      $$SettingsEntriesTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$TerminalsTableCreateCompanionBuilder = TerminalsCompanion Function({
  required String id,
  required int updatedAt,
  Value<bool> deleted,
  required String name,
  required String code,
  Value<int> lastSeenAt,
  Value<String> appVersion,
  Value<int> rowid,
});
typedef $$TerminalsTableUpdateCompanionBuilder = TerminalsCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<bool> deleted,
  Value<String> name,
  Value<String> code,
  Value<int> lastSeenAt,
  Value<String> appVersion,
  Value<int> rowid,
});

class $$TerminalsTableFilterComposer
    extends Composer<_$AppDatabase, $TerminalsTable> {
  $$TerminalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TerminalsTableOrderingComposer
    extends Composer<_$AppDatabase, $TerminalsTable> {
  $$TerminalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TerminalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TerminalsTable> {
  $$TerminalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );
}

class $$TerminalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TerminalsTable,
          Terminal,
          $$TerminalsTableFilterComposer,
          $$TerminalsTableOrderingComposer,
          $$TerminalsTableAnnotationComposer,
          $$TerminalsTableCreateCompanionBuilder,
          $$TerminalsTableUpdateCompanionBuilder,
          (Terminal, BaseReferences<_$AppDatabase, $TerminalsTable, Terminal>),
          Terminal,
          PrefetchHooks Function()
        > {
  $$TerminalsTableTableManager(_$AppDatabase db, $TerminalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TerminalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TerminalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TerminalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<int> lastSeenAt = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TerminalsCompanion(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                code: code,
                lastSeenAt: lastSeenAt,
                appVersion: appVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                Value<bool> deleted = const Value.absent(),
                required String name,
                required String code,
                Value<int> lastSeenAt = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TerminalsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                code: code,
                lastSeenAt: lastSeenAt,
                appVersion: appVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TerminalsTable, Terminal>(table),
                  BaseReferences<_$AppDatabase, $TerminalsTable, Terminal>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TerminalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TerminalsTable,
      Terminal,
      $$TerminalsTableFilterComposer,
      $$TerminalsTableOrderingComposer,
      $$TerminalsTableAnnotationComposer,
      $$TerminalsTableCreateCompanionBuilder,
      $$TerminalsTableUpdateCompanionBuilder,
      (Terminal, BaseReferences<_$AppDatabase, $TerminalsTable, Terminal>),
      Terminal,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  required String collection,
  required String docId,
  required String payload,
  required int createdAt,
  Value<int> attempts,
  Value<String?> lastError,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  Value<String> collection,
  Value<String> docId,
  Value<String> payload,
  Value<int> createdAt,
  Value<int> attempts,
  Value<String?> lastError,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docId => $composableBuilder(
    column: $table.docId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docId => $composableBuilder(
    column: $table.docId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get docId =>
      $composableBuilder(column: $table.docId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxEntry,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (
            OutboxEntry,
            BaseReferences<_$AppDatabase, $OutboxTable, OutboxEntry>,
          ),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> collection = const Value.absent(),
                Value<String> docId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => OutboxCompanion(
                seq: seq,
                collection: collection,
                docId: docId,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String collection,
                required String docId,
                required String payload,
                required int createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => OutboxCompanion.insert(
                seq: seq,
                collection: collection,
                docId: docId,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxTable, OutboxEntry>(table),
                  BaseReferences<_$AppDatabase, $OutboxTable, OutboxEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxEntry,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxEntry, BaseReferences<_$AppDatabase, $OutboxTable, OutboxEntry>),
      OutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$LocalMetaTableCreateCompanionBuilder = LocalMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$LocalMetaTableUpdateCompanionBuilder = LocalMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$LocalMetaTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMetaTable> {
  $$LocalMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMetaTable> {
  $$LocalMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMetaTable> {
  $$LocalMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$LocalMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMetaTable,
          LocalMetaEntry,
          $$LocalMetaTableFilterComposer,
          $$LocalMetaTableOrderingComposer,
          $$LocalMetaTableAnnotationComposer,
          $$LocalMetaTableCreateCompanionBuilder,
          $$LocalMetaTableUpdateCompanionBuilder,
          (
            LocalMetaEntry,
            BaseReferences<_$AppDatabase, $LocalMetaTable, LocalMetaEntry>,
          ),
          LocalMetaEntry,
          PrefetchHooks Function()
        > {
  $$LocalMetaTableTableManager(_$AppDatabase db, $LocalMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => LocalMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => LocalMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalMetaTable, LocalMetaEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalMetaTable,
                    LocalMetaEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMetaTable,
      LocalMetaEntry,
      $$LocalMetaTableFilterComposer,
      $$LocalMetaTableOrderingComposer,
      $$LocalMetaTableAnnotationComposer,
      $$LocalMetaTableCreateCompanionBuilder,
      $$LocalMetaTableUpdateCompanionBuilder,
      (
        LocalMetaEntry,
        BaseReferences<_$AppDatabase, $LocalMetaTable, LocalMetaEntry>,
      ),
      LocalMetaEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$ModifierGroupsTableTableManager get modifierGroups =>
      $$ModifierGroupsTableTableManager(_db, _db.modifierGroups);
  $$TaxesTableTableManager get taxes =>
      $$TaxesTableTableManager(_db, _db.taxes);
  $$PaymentMethodsTableTableManager get paymentMethods =>
      $$PaymentMethodsTableTableManager(_db, _db.paymentMethods);
  $$AreasTableTableManager get areas =>
      $$AreasTableTableManager(_db, _db.areas);
  $$DiningTablesTableTableManager get diningTables =>
      $$DiningTablesTableTableManager(_db, _db.diningTables);
  $$StaffTableTableManager get staff =>
      $$StaffTableTableManager(_db, _db.staff);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$RefundsTableTableManager get refunds =>
      $$RefundsTableTableManager(_db, _db.refunds);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$CashMovementsTableTableManager get cashMovements =>
      $$CashMovementsTableTableManager(_db, _db.cashMovements);
  $$StockItemsTableTableManager get stockItems =>
      $$StockItemsTableTableManager(_db, _db.stockItems);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$SettingsEntriesTableTableManager get settingsEntries =>
      $$SettingsEntriesTableTableManager(_db, _db.settingsEntries);
  $$TerminalsTableTableManager get terminals =>
      $$TerminalsTableTableManager(_db, _db.terminals);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$LocalMetaTableTableManager get localMeta =>
      $$LocalMetaTableTableManager(_db, _db.localMeta);
}
