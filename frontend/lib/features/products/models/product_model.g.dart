// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      spiceType: json['spiceType'] as String,
      price: (json['price'] as num).toDouble(),
      aiSuggestedPrice: (json['aiSuggestedPrice'] as num?)?.toDouble(),
      unit: json['unit'] as String,
      stock: (json['stock'] as num).toInt(),
      minOrder: (json['minOrder'] as num).toInt(),
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      sellerLocation: json['sellerLocation'] as String,
      sellerRating: (json['sellerRating'] as num?)?.toDouble(),
      origin: json['origin'] as String,
      harvestDate: json['harvestDate'] as String,
      quality: json['quality'] as String,
      isOrganic: json['isOrganic'] as bool,
      certifications: json['certifications'] as String?,
      specifications: json['specifications'] as Map<String, dynamic>?,
      status: $enumDecode(_$ProductStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      salesCount: (json['salesCount'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      shippingInfo: json['shippingInfo'] == null
          ? null
          : ShippingInfo.fromJson(json['shippingInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'spiceType': instance.spiceType,
      'price': instance.price,
      'aiSuggestedPrice': instance.aiSuggestedPrice,
      'unit': instance.unit,
      'stock': instance.stock,
      'minOrder': instance.minOrder,
      'images': instance.images,
      'sellerId': instance.sellerId,
      'sellerName': instance.sellerName,
      'sellerLocation': instance.sellerLocation,
      'sellerRating': instance.sellerRating,
      'origin': instance.origin,
      'harvestDate': instance.harvestDate,
      'quality': instance.quality,
      'isOrganic': instance.isOrganic,
      'certifications': instance.certifications,
      'specifications': instance.specifications,
      'status': _$ProductStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
      'viewCount': instance.viewCount,
      'salesCount': instance.salesCount,
      'averageRating': instance.averageRating,
      'tags': instance.tags,
      'shippingInfo': instance.shippingInfo,
    };

const _$ProductStatusEnumMap = {
  ProductStatus.draft: 'DRAFT',
  ProductStatus.pendingReview: 'PENDING_REVIEW',
  ProductStatus.active: 'ACTIVE',
  ProductStatus.inactive: 'INACTIVE',
  ProductStatus.rejected: 'REJECTED',
  ProductStatus.soldOut: 'SOLD_OUT',
};

ShippingInfo _$ShippingInfoFromJson(Map<String, dynamic> json) => ShippingInfo(
      weight: (json['weight'] as num).toDouble(),
      dimensions: json['dimensions'] as String,
      fragile: json['fragile'] as bool,
      packagingType: json['packagingType'] as String,
      availableShipping: (json['availableShipping'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      processingTime: (json['processingTime'] as num).toInt(),
    );

Map<String, dynamic> _$ShippingInfoToJson(ShippingInfo instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'fragile': instance.fragile,
      'packagingType': instance.packagingType,
      'availableShipping': instance.availableShipping,
      'processingTime': instance.processingTime,
    };
