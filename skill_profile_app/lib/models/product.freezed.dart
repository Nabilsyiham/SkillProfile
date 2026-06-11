// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  dynamic get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get material => throw _privateConstructorUsedError;
  dynamic get price => throw _privateConstructorUsedError;
  String get img => throw _privateConstructorUsedError;
  bool get isFlashSale => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_percent')
  int get discountPercent => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call({
    dynamic id,
    String name,
    String category,
    String material,
    dynamic price,
    String img,
    bool isFlashSale,
    @JsonKey(name: 'discount_percent') int discountPercent,
  });
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? category = null,
    Object? material = null,
    Object? price = freezed,
    Object? img = null,
    Object? isFlashSale = null,
    Object? discountPercent = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            material: null == material
                ? _value.material
                : material // ignore: cast_nullable_to_non_nullable
                      as String,
            price: freezed == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            img: null == img
                ? _value.img
                : img // ignore: cast_nullable_to_non_nullable
                      as String,
            isFlashSale: null == isFlashSale
                ? _value.isFlashSale
                : isFlashSale // ignore: cast_nullable_to_non_nullable
                      as bool,
            discountPercent: null == discountPercent
                ? _value.discountPercent
                : discountPercent // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
    _$ProductImpl value,
    $Res Function(_$ProductImpl) then,
  ) = __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    dynamic id,
    String name,
    String category,
    String material,
    dynamic price,
    String img,
    bool isFlashSale,
    @JsonKey(name: 'discount_percent') int discountPercent,
  });
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
    _$ProductImpl _value,
    $Res Function(_$ProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? category = null,
    Object? material = null,
    Object? price = freezed,
    Object? img = null,
    Object? isFlashSale = null,
    Object? discountPercent = null,
  }) {
    return _then(
      _$ProductImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        material: null == material
            ? _value.material
            : material // ignore: cast_nullable_to_non_nullable
                  as String,
        price: freezed == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        img: null == img
            ? _value.img
            : img // ignore: cast_nullable_to_non_nullable
                  as String,
        isFlashSale: null == isFlashSale
            ? _value.isFlashSale
            : isFlashSale // ignore: cast_nullable_to_non_nullable
                  as bool,
        discountPercent: null == discountPercent
            ? _value.discountPercent
            : discountPercent // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImpl extends _Product {
  const _$ProductImpl({
    required this.id,
    required this.name,
    required this.category,
    required this.material,
    required this.price,
    required this.img,
    this.isFlashSale = false,
    @JsonKey(name: 'discount_percent') this.discountPercent = 0,
  }) : super._();

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  @override
  final dynamic id;
  @override
  final String name;
  @override
  final String category;
  @override
  final String material;
  @override
  final dynamic price;
  @override
  final String img;
  @override
  @JsonKey()
  final bool isFlashSale;
  @override
  @JsonKey(name: 'discount_percent')
  final int discountPercent;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, category: $category, material: $material, price: $price, img: $img, isFlashSale: $isFlashSale, discountPercent: $discountPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.material, material) ||
                other.material == material) &&
            const DeepCollectionEquality().equals(other.price, price) &&
            (identical(other.img, img) || other.img == img) &&
            (identical(other.isFlashSale, isFlashSale) ||
                other.isFlashSale == isFlashSale) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(id),
    name,
    category,
    material,
    const DeepCollectionEquality().hash(price),
    img,
    isFlashSale,
    discountPercent,
  );

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(this);
  }
}

abstract class _Product extends Product {
  const factory _Product({
    required final dynamic id,
    required final String name,
    required final String category,
    required final String material,
    required final dynamic price,
    required final String img,
    final bool isFlashSale,
    @JsonKey(name: 'discount_percent') final int discountPercent,
  }) = _$ProductImpl;
  const _Product._() : super._();

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  @override
  dynamic get id;
  @override
  String get name;
  @override
  String get category;
  @override
  String get material;
  @override
  dynamic get price;
  @override
  String get img;
  @override
  bool get isFlashSale;
  @override
  @JsonKey(name: 'discount_percent')
  int get discountPercent;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
