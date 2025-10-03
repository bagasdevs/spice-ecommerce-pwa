import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final String spiceType;
  final double price;
  final double? aiSuggestedPrice;
  final String unit; // kg, gram, etc.
  final int stock;
  final int minOrder;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final String sellerLocation;
  final double? sellerRating;
  final String origin; // Asal daerah rempah
  final String harvestDate;
  final String quality; // Premium, Standard, etc.
  final bool isOrganic;
  final String? certifications;
  final Map<String, dynamic>? specifications; // Moisture content, etc.
  final ProductStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int viewCount;
  final int salesCount;
  final double? averageRating;
  final List<String> tags;
  final ShippingInfo? shippingInfo;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.spiceType,
    required this.price,
    this.aiSuggestedPrice,
    required this.unit,
    required this.stock,
    required this.minOrder,
    required this.images,
    required this.sellerId,
    required this.sellerName,
    required this.sellerLocation,
    this.sellerRating,
    required this.origin,
    required this.harvestDate,
    required this.quality,
    required this.isOrganic,
    this.certifications,
    this.specifications,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.viewCount = 0,
    this.salesCount = 0,
    this.averageRating,
    this.tags = const [],
    this.shippingInfo,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? spiceType,
    double? price,
    double? aiSuggestedPrice,
    String? unit,
    int? stock,
    int? minOrder,
    List<String>? images,
    String? sellerId,
    String? sellerName,
    String? sellerLocation,
    double? sellerRating,
    String? origin,
    String? harvestDate,
    String? quality,
    bool? isOrganic,
    String? certifications,
    Map<String, dynamic>? specifications,
    ProductStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? viewCount,
    int? salesCount,
    double? averageRating,
    List<String>? tags,
    ShippingInfo? shippingInfo,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      spiceType: spiceType ?? this.spiceType,
      price: price ?? this.price,
      aiSuggestedPrice: aiSuggestedPrice ?? this.aiSuggestedPrice,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      minOrder: minOrder ?? this.minOrder,
      images: images ?? this.images,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerLocation: sellerLocation ?? this.sellerLocation,
      sellerRating: sellerRating ?? this.sellerRating,
      origin: origin ?? this.origin,
      harvestDate: harvestDate ?? this.harvestDate,
      quality: quality ?? this.quality,
      isOrganic: isOrganic ?? this.isOrganic,
      certifications: certifications ?? this.certifications,
      specifications: specifications ?? this.specifications,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
      salesCount: salesCount ?? this.salesCount,
      averageRating: averageRating ?? this.averageRating,
      tags: tags ?? this.tags,
      shippingInfo: shippingInfo ?? this.shippingInfo,
    );
  }

  bool get isInStock => stock > 0;
  bool get isLowStock => stock > 0 && stock <= 10;
  bool get hasAiInsight => aiSuggestedPrice != null;

  double get pricePerKg {
    switch (unit.toLowerCase()) {
      case 'gram':
        return price * 1000;
      case 'kg':
        return price;
      default:
        return price;
    }
  }

  String get displayPrice =>
      'Rp ${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  String get displayPricePerKg =>
      'Rp ${pricePerKg.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class ShippingInfo {
  final double weight;
  final String dimensions; // "20x15x10 cm"
  final bool fragile;
  final String packagingType;
  final List<String> availableShipping; // JNE, TIKI, POS, etc.
  final int processingTime; // days

  const ShippingInfo({
    required this.weight,
    required this.dimensions,
    required this.fragile,
    required this.packagingType,
    required this.availableShipping,
    required this.processingTime,
  });

  factory ShippingInfo.fromJson(Map<String, dynamic> json) =>
      _$ShippingInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ShippingInfoToJson(this);
}

enum ProductStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('PENDING_REVIEW')
  pendingReview,
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('SOLD_OUT')
  soldOut;

  String get displayName {
    switch (this) {
      case ProductStatus.draft:
        return 'Draft';
      case ProductStatus.pendingReview:
        return 'Menunggu Review';
      case ProductStatus.active:
        return 'Aktif';
      case ProductStatus.inactive:
        return 'Tidak Aktif';
      case ProductStatus.rejected:
        return 'Ditolak';
      case ProductStatus.soldOut:
        return 'Habis';
    }
  }
}

// Common spice categories
class SpiceCategories {
  static const List<String> categories = [
    'Rempah Basah',
    'Rempah Kering',
    'Umbi-umbian',
    'Daun Rempah',
    'Biji-bijian',
    'Kulit & Batang',
  ];

  static const Map<String, List<String>> spiceTypes = {
    'Rempah Basah': [
      'Jahe Merah',
      'Jahe Putih',
      'Kunyit',
      'Lengkuas',
      'Kencur',
      'Temulawak',
      'Temu Kunci',
    ],
    'Rempah Kering': [
      'Cabe Kering',
      'Merica Putih',
      'Merica Hitam',
      'Ketumbar',
      'Jinten',
      'Adas',
      'Kemiri',
    ],
    'Umbi-umbian': [
      'Bawang Merah',
      'Bawang Putih',
      'Bawang Bombay',
    ],
    'Daun Rempah': [
      'Daun Jeruk',
      'Daun Salam',
      'Daun Pandan',
      'Serai',
      'Kemangi',
    ],
    'Biji-bijian': [
      'Pala',
      'Kapulaga',
      'Cengkeh',
      'Biji Wijen',
    ],
    'Kulit & Batang': [
      'Kayu Manis',
      'Kulit Pala',
      'Asam Jawa',
    ],
  };

  static List<String> getSpiceTypes(String category) {
    return spiceTypes[category] ?? [];
  }

  static List<String> getAllSpiceTypes() {
    return spiceTypes.values.expand((types) => types).toList();
  }
}
