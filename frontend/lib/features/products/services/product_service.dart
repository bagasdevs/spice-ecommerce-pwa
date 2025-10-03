import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/product_model.dart';

class ProductService {
  final Dio _dio;
  final String _baseUrl;

  ProductService({
    required Dio dio,
    String? baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl ?? AppConstants.baseUrl;

  // Get all products with filtering and pagination
  Future<ProductListResponse> getProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? spiceType,
    String? searchQuery,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? sortBy = 'createdAt',
    String? sortOrder = 'desc',
    bool? isOrganic,
    ProductStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (category != null) queryParams['category'] = category;
      if (spiceType != null) queryParams['spiceType'] = spiceType;
      if (searchQuery != null) queryParams['search'] = searchQuery;
      if (location != null) queryParams['location'] = location;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (isOrganic != null) queryParams['isOrganic'] = isOrganic;
      if (status != null) queryParams['status'] = status.name.toUpperCase();

      final response = await _dio.get(
        '$_baseUrl/api/products',
        queryParameters: queryParams,
      );

      return ProductListResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get seller's products
  Future<ProductListResponse> getSellerProducts({
    required String sellerId,
    int page = 1,
    int limit = 20,
    ProductStatus? status,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/products/seller/$sellerId',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status.name.toUpperCase(),
        },
      );

      return ProductListResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get product by ID
  Future<Product> getProductById(String productId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/products/$productId');
      return Product.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Create new product
  Future<Product> createProduct({
    required String name,
    required String description,
    required String category,
    required String spiceType,
    required double price,
    required String unit,
    required int stock,
    required int minOrder,
    required List<File> imageFiles,
    required String origin,
    required String harvestDate,
    required String quality,
    required bool isOrganic,
    String? certifications,
    Map<String, dynamic>? specifications,
    ShippingInfo? shippingInfo,
    List<String>? tags,
  }) async {
    try {
      final formData = FormData();

      // Add text fields
      formData.fields.addAll([
        MapEntry('name', name),
        MapEntry('description', description),
        MapEntry('category', category),
        MapEntry('spiceType', spiceType),
        MapEntry('price', price.toString()),
        MapEntry('unit', unit),
        MapEntry('stock', stock.toString()),
        MapEntry('minOrder', minOrder.toString()),
        MapEntry('origin', origin),
        MapEntry('harvestDate', harvestDate),
        MapEntry('quality', quality),
        MapEntry('isOrganic', isOrganic.toString()),
      ]);

      if (certifications != null) {
        formData.fields.add(MapEntry('certifications', certifications));
      }

      if (specifications != null) {
        formData.fields
            .add(MapEntry('specifications', jsonEncode(specifications)));
      }

      if (shippingInfo != null) {
        formData.fields
            .add(MapEntry('shippingInfo', jsonEncode(shippingInfo.toJson())));
      }

      if (tags != null && tags.isNotEmpty) {
        formData.fields.add(MapEntry('tags', jsonEncode(tags)));
      }

      // Add image files
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              file.path,
              filename: 'product_image_$i.${file.path.split('.').last}',
            ),
          ),
        );
      }

      final response = await _dio.post(
        '$_baseUrl/api/products',
        data: formData,
      );

      return Product.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update product
  Future<Product> updateProduct({
    required String productId,
    String? name,
    String? description,
    String? category,
    String? spiceType,
    double? price,
    String? unit,
    int? stock,
    int? minOrder,
    List<File>? newImageFiles,
    List<String>? existingImages,
    String? origin,
    String? harvestDate,
    String? quality,
    bool? isOrganic,
    String? certifications,
    Map<String, dynamic>? specifications,
    ShippingInfo? shippingInfo,
    List<String>? tags,
    ProductStatus? status,
  }) async {
    try {
      final formData = FormData();

      // Add only non-null fields
      if (name != null) formData.fields.add(MapEntry('name', name));
      if (description != null)
        formData.fields.add(MapEntry('description', description));
      if (category != null) formData.fields.add(MapEntry('category', category));
      if (spiceType != null)
        formData.fields.add(MapEntry('spiceType', spiceType));
      if (price != null)
        formData.fields.add(MapEntry('price', price.toString()));
      if (unit != null) formData.fields.add(MapEntry('unit', unit));
      if (stock != null)
        formData.fields.add(MapEntry('stock', stock.toString()));
      if (minOrder != null)
        formData.fields.add(MapEntry('minOrder', minOrder.toString()));
      if (origin != null) formData.fields.add(MapEntry('origin', origin));
      if (harvestDate != null)
        formData.fields.add(MapEntry('harvestDate', harvestDate));
      if (quality != null) formData.fields.add(MapEntry('quality', quality));
      if (isOrganic != null)
        formData.fields.add(MapEntry('isOrganic', isOrganic.toString()));
      if (certifications != null)
        formData.fields.add(MapEntry('certifications', certifications));
      if (status != null)
        formData.fields.add(MapEntry('status', status.name.toUpperCase()));

      if (specifications != null) {
        formData.fields
            .add(MapEntry('specifications', jsonEncode(specifications)));
      }

      if (shippingInfo != null) {
        formData.fields
            .add(MapEntry('shippingInfo', jsonEncode(shippingInfo.toJson())));
      }

      if (tags != null) {
        formData.fields.add(MapEntry('tags', jsonEncode(tags)));
      }

      if (existingImages != null) {
        formData.fields
            .add(MapEntry('existingImages', jsonEncode(existingImages)));
      }

      // Add new image files if any
      if (newImageFiles != null) {
        for (int i = 0; i < newImageFiles.length; i++) {
          final file = newImageFiles[i];
          formData.files.add(
            MapEntry(
              'newImages',
              await MultipartFile.fromFile(
                file.path,
                filename:
                    'product_image_${DateTime.now().millisecondsSinceEpoch}_$i.${file.path.split('.').last}',
              ),
            ),
          );
        }
      }

      final response = await _dio.put(
        '$_baseUrl/api/products/$productId',
        data: formData,
      );

      return Product.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _dio.delete('$_baseUrl/api/products/$productId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get AI price suggestion
  Future<AiPriceInsight> getAiPriceInsight({
    required String spiceType,
    required String quality,
    required String origin,
    required bool isOrganic,
    Map<String, dynamic>? specifications,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/ai/price-insight',
        data: {
          'spiceType': spiceType,
          'quality': quality,
          'origin': origin,
          'isOrganic': isOrganic,
          if (specifications != null) 'specifications': specifications,
        },
      );

      return AiPriceInsight.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get product analytics for seller
  Future<ProductAnalytics> getProductAnalytics(String productId) async {
    try {
      final response =
          await _dio.get('$_baseUrl/api/products/$productId/analytics');
      return ProductAnalytics.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Search products with advanced filters
  Future<ProductListResponse> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    List<String>? categories,
    List<String>? spiceTypes,
    double? minPrice,
    double? maxPrice,
    String? location,
    bool? isOrganic,
    double? minRating,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/products/search',
        data: {
          'query': query,
          'page': page,
          'limit': limit,
          if (categories != null) 'categories': categories,
          if (spiceTypes != null) 'spiceTypes': spiceTypes,
          if (minPrice != null) 'minPrice': minPrice,
          if (maxPrice != null) 'maxPrice': maxPrice,
          if (location != null) 'location': location,
          if (isOrganic != null) 'isOrganic': isOrganic,
          if (minRating != null) 'minRating': minRating,
        },
      );

      return ProductListResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update product view count
  Future<void> incrementViewCount(String productId) async {
    try {
      await _dio.post('$_baseUrl/api/products/$productId/view');
    } catch (e) {
      // Non-critical operation, don't throw
      print('Failed to increment view count: $e');
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception(
              'Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message =
              error.response?.data?['message'] ?? 'Unknown error occurred';

          switch (statusCode) {
            case 400:
              return Exception('Bad request: $message');
            case 401:
              return Exception('Authentication required. Please login again.');
            case 403:
              return Exception('Access denied: $message');
            case 404:
              return Exception('Product not found');
            case 429:
              return Exception('Too many requests. Please try again later.');
            case 500:
              return Exception('Server error. Please try again later.');
            default:
              return Exception('Error: $message');
          }
        case DioExceptionType.cancel:
          return Exception('Request was cancelled');
        default:
          return Exception('Network error. Please check your connection.');
      }
    }

    return Exception('Unexpected error: ${error.toString()}');
  }
}

// Response models
class ProductListResponse {
  final List<Product> products;
  final int total;
  final int page;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  ProductListResponse({
    required this.products,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      products:
          (json['data'] as List).map((item) => Product.fromJson(item)).toList(),
      total: json['pagination']['total'],
      page: json['pagination']['page'],
      totalPages: json['pagination']['totalPages'],
      hasNext: json['pagination']['hasNext'],
      hasPrev: json['pagination']['hasPrev'],
    );
  }
}

class AiPriceInsight {
  final double suggestedPrice;
  final double minPrice;
  final double maxPrice;
  final double confidence;
  final String reasoning;
  final Map<String, dynamic> marketData;
  final List<String> recommendations;

  AiPriceInsight({
    required this.suggestedPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.confidence,
    required this.reasoning,
    required this.marketData,
    required this.recommendations,
  });

  factory AiPriceInsight.fromJson(Map<String, dynamic> json) {
    return AiPriceInsight(
      suggestedPrice: json['suggestedPrice'].toDouble(),
      minPrice: json['minPrice'].toDouble(),
      maxPrice: json['maxPrice'].toDouble(),
      confidence: json['confidence'].toDouble(),
      reasoning: json['reasoning'],
      marketData: json['marketData'],
      recommendations: List<String>.from(json['recommendations']),
    );
  }
}

class ProductAnalytics {
  final int viewCount;
  final int salesCount;
  final double revenue;
  final double averageRating;
  final Map<String, int> viewsByDate;
  final Map<String, int> salesByDate;
  final List<String> topSearchKeywords;

  ProductAnalytics({
    required this.viewCount,
    required this.salesCount,
    required this.revenue,
    required this.averageRating,
    required this.viewsByDate,
    required this.salesByDate,
    required this.topSearchKeywords,
  });

  factory ProductAnalytics.fromJson(Map<String, dynamic> json) {
    return ProductAnalytics(
      viewCount: json['viewCount'],
      salesCount: json['salesCount'],
      revenue: json['revenue'].toDouble(),
      averageRating: json['averageRating'].toDouble(),
      viewsByDate: Map<String, int>.from(json['viewsByDate']),
      salesByDate: Map<String, int>.from(json['salesByDate']),
      topSearchKeywords: List<String>.from(json['topSearchKeywords']),
    );
  }
}

// Provider
final productServiceProvider = Provider<ProductService>((ref) {
  final dio = Dio();
  final authNotifier = ref.watch(authProvider.notifier);

  // Add auth interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = authNotifier.authToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  return ProductService(dio: dio);
});
