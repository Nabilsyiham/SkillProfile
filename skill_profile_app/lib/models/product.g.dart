// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'],
      name: json['name'] as String,
      category: json['category'] as String,
      material: json['material'] as String,
      price: json['price'],
      img: json['img'] as String,
      isFlashSale: json['isFlashSale'] as bool? ?? false,
      discountPercent: (json['discount_percent'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'material': instance.material,
      'price': instance.price,
      'img': instance.img,
      'isFlashSale': instance.isFlashSale,
      'discount_percent': instance.discountPercent,
    };
