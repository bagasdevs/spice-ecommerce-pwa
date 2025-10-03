import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

// Product list state
class ProductListState {
  final List<Product> products;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int currentPage;
  final String? searchQuery;
  final String? selectedCategory;
  final String? selectedSpiceType;
  final double? minPrice;
  final double? maxPrice;
  final bool? isOrganic;
  final String? location;
  final String sortBy;
  final String sortOrder;

  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 1,
    this.searchQuery,
    this.selectedCategory,
    this.selectedSpiceType,
    this.minPrice,
    this.maxPrice,
    this.isOrganic,
    this.location,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  ProductListState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? currentPage,
    String? searchQuery,
    String? selectedCategory,
    String? selectedSpiceType,
    double? minPrice,
    double? maxPrice,
    bool? isOrganic,
    String? location,
    String? sortBy,
    String? sortOrder,
    bool clearError = false,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSpiceType: selectedSpiceType ?? this.selectedSpiceType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      isOrganic: isOrganic ?? this.isOrganic,
      location: location ?? this.location,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

// Product list provider
class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductService _productService;

  ProductListNotifier(this._productService) : super(const ProductListState());

  // Load products with current filters
  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(
        products: [],
        currentPage: 1,
        hasMore: true,
        isLoading: true,
        clearError: true,
      );
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final response = await _productService.getProducts(
        page: refresh ? 1 : state.currentPage,
        category: state.selectedCategory,
        spiceType: state.selectedSpiceType,
        searchQuery: state.searchQuery,
        location: state.location,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        isOrganic: state.isOrganic,
        sortBy: state.sortBy,
        sortOrder: state.sortOrder,
      );

      final newProducts = refresh
          ? response.products
          : [...state.products, ...response.products];

      state = state.copyWith(
        products: newProducts,
        isLoading: false,
        hasMore: response.hasNext,
        currentPage: response.page + (response.hasNext ? 1 : 0),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load more products (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadProducts();
  }

  // Search products
  Future<void> searchProducts(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadProducts(refresh: true);
  }

  // Filter by category
  void filterByCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    loadProducts(refresh: true);
  }

  // Filter by spice type
  void filterBySpiceType(String? spiceType) {
    state = state.copyWith(selectedSpiceType: spiceType);
    loadProducts(refresh: true);
  }

  // Filter by price range
  void filterByPriceRange(double? minPrice, double? maxPrice) {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice);
    loadProducts(refresh: true);
  }

  // Filter by organic
  void filterByOrganic(bool? isOrganic) {
    state = state.copyWith(isOrganic: isOrganic);
    loadProducts(refresh: true);
  }

  // Filter by location
  void filterByLocation(String? location) {
    state = state.copyWith(location: location);
    loadProducts(refresh: true);
  }

  // Change sort order
  void sortBy(String sortBy, String sortOrder) {
    state = state.copyWith(sortBy: sortBy, sortOrder: sortOrder);
    loadProducts(refresh: true);
  }

  // Clear all filters
  void clearFilters() {
    state = const ProductListState();
    loadProducts(refresh: true);
  }

  // Refresh products
  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }
}

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final productService = ref.watch(productServiceProvider);
  return ProductListNotifier(productService);
});

// Single product state
class ProductState {
  final Product? product;
  final bool isLoading;
  final String? error;

  const ProductState({
    this.product,
    this.isLoading = false,
    this.error,
  });

  ProductState copyWith({
    Product? product,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProductState(
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Single product provider
class ProductNotifier extends StateNotifier<ProductState> {
  final ProductService _productService;

  ProductNotifier(this._productService) : super(const ProductState());

  // Load product by ID
  Future<void> loadProduct(String productId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final product = await _productService.getProductById(productId);

      // Increment view count (non-blocking)
      _productService.incrementViewCount(productId);

      state = state.copyWith(
        product: product,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear product
  void clearProduct() {
    state = const ProductState();
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final productService = ref.watch(productServiceProvider);
  return ProductNotifier(productService);
});

// Seller products state
class SellerProductsState {
  final List<Product> products;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int currentPage;
  final ProductStatus? statusFilter;

  const SellerProductsState({
    this.products = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 1,
    this.statusFilter,
  });

  SellerProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? currentPage,
    ProductStatus? statusFilter,
    bool clearError = false,
  }) {
    return SellerProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

// Seller products provider
class SellerProductsNotifier extends StateNotifier<SellerProductsState> {
  final ProductService _productService;
  final String sellerId;

  SellerProductsNotifier(this._productService, this.sellerId)
      : super(const SellerProductsState());

  // Load seller products
  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(
        products: [],
        currentPage: 1,
        hasMore: true,
        isLoading: true,
        clearError: true,
      );
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final response = await _productService.getSellerProducts(
        sellerId: sellerId,
        page: refresh ? 1 : state.currentPage,
        status: state.statusFilter,
      );

      final newProducts = refresh
          ? response.products
          : [...state.products, ...response.products];

      state = state.copyWith(
        products: newProducts,
        isLoading: false,
        hasMore: response.hasNext,
        currentPage: response.page + (response.hasNext ? 1 : 0),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Filter by status
  void filterByStatus(ProductStatus? status) {
    state = state.copyWith(statusFilter: status);
    loadProducts(refresh: true);
  }

  // Add new product to list
  void addProduct(Product product) {
    state = state.copyWith(products: [product, ...state.products]);
  }

  // Update product in list
  void updateProduct(Product updatedProduct) {
    final updatedProducts = state.products
        .map((product) =>
            product.id == updatedProduct.id ? updatedProduct : product)
        .toList();
    state = state.copyWith(products: updatedProducts);
  }

  // Remove product from list
  void removeProduct(String productId) {
    final updatedProducts =
        state.products.where((product) => product.id != productId).toList();
    state = state.copyWith(products: updatedProducts);
  }

  // Load more products (pagination)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    await loadProducts();
  }

  // Refresh products
  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }
}

final sellerProductsProvider = StateNotifierProvider.family<
    SellerProductsNotifier, SellerProductsState, String>((ref, sellerId) {
  final productService = ref.watch(productServiceProvider);
  return SellerProductsNotifier(productService, sellerId);
});

// Product form state for creating/editing
class ProductFormState {
  final String name;
  final String description;
  final String category;
  final String spiceType;
  final double? price;
  final String unit;
  final int? stock;
  final int? minOrder;
  final List<File> imageFiles;
  final List<String> existingImages;
  final String origin;
  final String harvestDate;
  final String quality;
  final bool isOrganic;
  final String? certifications;
  final Map<String, dynamic> specifications;
  final ShippingInfo? shippingInfo;
  final List<String> tags;
  final bool isLoading;
  final String? error;
  final AiPriceInsight? aiInsight;
  final bool loadingAiInsight;

  const ProductFormState({
    this.name = '',
    this.description = '',
    this.category = '',
    this.spiceType = '',
    this.price,
    this.unit = 'kg',
    this.stock,
    this.minOrder,
    this.imageFiles = const [],
    this.existingImages = const [],
    this.origin = '',
    this.harvestDate = '',
    this.quality = 'Standard',
    this.isOrganic = false,
    this.certifications,
    this.specifications = const {},
    this.shippingInfo,
    this.tags = const [],
    this.isLoading = false,
    this.error,
    this.aiInsight,
    this.loadingAiInsight = false,
  });

  ProductFormState copyWith({
    String? name,
    String? description,
    String? category,
    String? spiceType,
    double? price,
    String? unit,
    int? stock,
    int? minOrder,
    List<File>? imageFiles,
    List<String>? existingImages,
    String? origin,
    String? harvestDate,
    String? quality,
    bool? isOrganic,
    String? certifications,
    Map<String, dynamic>? specifications,
    ShippingInfo? shippingInfo,
    List<String>? tags,
    bool? isLoading,
    String? error,
    AiPriceInsight? aiInsight,
    bool? loadingAiInsight,
    bool clearError = false,
    bool clearAiInsight = false,
  }) {
    return ProductFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      spiceType: spiceType ?? this.spiceType,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      minOrder: minOrder ?? this.minOrder,
      imageFiles: imageFiles ?? this.imageFiles,
      existingImages: existingImages ?? this.existingImages,
      origin: origin ?? this.origin,
      harvestDate: harvestDate ?? this.harvestDate,
      quality: quality ?? this.quality,
      isOrganic: isOrganic ?? this.isOrganic,
      certifications: certifications ?? this.certifications,
      specifications: specifications ?? this.specifications,
      shippingInfo: shippingInfo ?? this.shippingInfo,
      tags: tags ?? this.tags,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      aiInsight: clearAiInsight ? null : (aiInsight ?? this.aiInsight),
      loadingAiInsight: loadingAiInsight ?? this.loadingAiInsight,
    );
  }

  bool get isValid {
    return name.isNotEmpty &&
        description.isNotEmpty &&
        category.isNotEmpty &&
        spiceType.isNotEmpty &&
        price != null &&
        price! > 0 &&
        stock != null &&
        stock! >= 0 &&
        minOrder != null &&
        minOrder! > 0 &&
        (imageFiles.isNotEmpty || existingImages.isNotEmpty) &&
        origin.isNotEmpty &&
        harvestDate.isNotEmpty;
  }
}

// Product form provider
class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final ProductService _productService;

  ProductFormNotifier(this._productService) : super(const ProductFormState());

  // Initialize form with existing product
  void initializeWithProduct(Product product) {
    state = ProductFormState(
      name: product.name,
      description: product.description,
      category: product.category,
      spiceType: product.spiceType,
      price: product.price,
      unit: product.unit,
      stock: product.stock,
      minOrder: product.minOrder,
      existingImages: product.images,
      origin: product.origin,
      harvestDate: product.harvestDate,
      quality: product.quality,
      isOrganic: product.isOrganic,
      certifications: product.certifications,
      specifications: product.specifications ?? {},
      shippingInfo: product.shippingInfo,
      tags: product.tags,
    );
  }

  // Update form fields
  void updateField(String field, dynamic value) {
    switch (field) {
      case 'name':
        state = state.copyWith(name: value);
        break;
      case 'description':
        state = state.copyWith(description: value);
        break;
      case 'category':
        state = state.copyWith(category: value, spiceType: '');
        break;
      case 'spiceType':
        state = state.copyWith(spiceType: value);
        break;
      case 'price':
        state = state.copyWith(price: value);
        break;
      case 'unit':
        state = state.copyWith(unit: value);
        break;
      case 'stock':
        state = state.copyWith(stock: value);
        break;
      case 'minOrder':
        state = state.copyWith(minOrder: value);
        break;
      case 'origin':
        state = state.copyWith(origin: value);
        break;
      case 'harvestDate':
        state = state.copyWith(harvestDate: value);
        break;
      case 'quality':
        state = state.copyWith(quality: value);
        break;
      case 'isOrganic':
        state = state.copyWith(isOrganic: value);
        break;
      case 'certifications':
        state = state.copyWith(certifications: value);
        break;
    }
  }

  // Add image file
  void addImageFile(File file) {
    state = state.copyWith(imageFiles: [...state.imageFiles, file]);
  }

  // Remove image file
  void removeImageFile(int index) {
    final files = List<File>.from(state.imageFiles);
    files.removeAt(index);
    state = state.copyWith(imageFiles: files);
  }

  // Remove existing image
  void removeExistingImage(int index) {
    final images = List<String>.from(state.existingImages);
    images.removeAt(index);
    state = state.copyWith(existingImages: images);
  }

  // Add tag
  void addTag(String tag) {
    if (!state.tags.contains(tag)) {
      state = state.copyWith(tags: [...state.tags, tag]);
    }
  }

  // Remove tag
  void removeTag(String tag) {
    final tags = List<String>.from(state.tags);
    tags.remove(tag);
    state = state.copyWith(tags: tags);
  }

  // Update specifications
  void updateSpecification(String key, dynamic value) {
    final specs = Map<String, dynamic>.from(state.specifications);
    specs[key] = value;
    state = state.copyWith(specifications: specs);
  }

  // Get AI price insight
  Future<void> getAiPriceInsight() async {
    if (state.spiceType.isEmpty || state.origin.isEmpty) return;

    state = state.copyWith(loadingAiInsight: true, clearError: true);

    try {
      final insight = await _productService.getAiPriceInsight(
        spiceType: state.spiceType,
        quality: state.quality,
        origin: state.origin,
        isOrganic: state.isOrganic,
        specifications:
            state.specifications.isNotEmpty ? state.specifications : null,
      );

      state = state.copyWith(
        aiInsight: insight,
        loadingAiInsight: false,
      );
    } catch (e) {
      state = state.copyWith(
        loadingAiInsight: false,
        error: e.toString(),
      );
    }
  }

  // Create product
  Future<Product?> createProduct() async {
    if (!state.isValid) return null;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final product = await _productService.createProduct(
        name: state.name,
        description: state.description,
        category: state.category,
        spiceType: state.spiceType,
        price: state.price!,
        unit: state.unit,
        stock: state.stock!,
        minOrder: state.minOrder!,
        imageFiles: state.imageFiles,
        origin: state.origin,
        harvestDate: state.harvestDate,
        quality: state.quality,
        isOrganic: state.isOrganic,
        certifications: state.certifications,
        specifications:
            state.specifications.isNotEmpty ? state.specifications : null,
        shippingInfo: state.shippingInfo,
        tags: state.tags.isNotEmpty ? state.tags : null,
      );

      state = state.copyWith(isLoading: false);
      return product;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Update product
  Future<Product?> updateProduct(String productId) async {
    if (!state.isValid) return null;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final product = await _productService.updateProduct(
        productId: productId,
        name: state.name,
        description: state.description,
        category: state.category,
        spiceType: state.spiceType,
        price: state.price,
        unit: state.unit,
        stock: state.stock,
        minOrder: state.minOrder,
        newImageFiles: state.imageFiles.isNotEmpty ? state.imageFiles : null,
        existingImages: state.existingImages,
        origin: state.origin,
        harvestDate: state.harvestDate,
        quality: state.quality,
        isOrganic: state.isOrganic,
        certifications: state.certifications,
        specifications:
            state.specifications.isNotEmpty ? state.specifications : null,
        shippingInfo: state.shippingInfo,
        tags: state.tags.isNotEmpty ? state.tags : null,
      );

      state = state.copyWith(isLoading: false);
      return product;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Reset form
  void resetForm() {
    state = const ProductFormState();
  }
}

final productFormProvider =
    StateNotifierProvider<ProductFormNotifier, ProductFormState>((ref) {
  final productService = ref.watch(productServiceProvider);
  return ProductFormNotifier(productService);
});
