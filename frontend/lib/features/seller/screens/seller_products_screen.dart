import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../../products/models/product_model.dart';
import '../../products/providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'product_form_screen.dart';

class SellerProductsScreen extends ConsumerStatefulWidget {
  const SellerProductsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SellerProductsScreen> createState() =>
      _SellerProductsScreenState();
}

class _SellerProductsScreenState extends ConsumerState<SellerProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      if (auth.user != null) {
        ref
            .read(sellerProductsProvider(auth.user!.id).notifier)
            .loadProducts(refresh: true);
      }
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        final auth = ref.read(authProvider);
        if (auth.user != null) {
          ref.read(sellerProductsProvider(auth.user!.id).notifier).loadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final sellerProducts =
        ref.watch(sellerProductsProvider(auth.user?.id ?? ''));

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(sellerProducts),
          _buildTabBar(),
          Expanded(child: _buildTabBarView(sellerProducts)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddProduct(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Tambah Produk', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader(SellerProductsState sellerProducts) {
    final totalProducts = sellerProducts.products.length;
    final activeProducts = sellerProducts.products
        .where((p) => p.status == ProductStatus.active)
        .length;
    final draftProducts = sellerProducts.products
        .where((p) => p.status == ProductStatus.draft)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelola Produk',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Produk',
                  totalProducts.toString(),
                  Icons.inventory_2_outlined,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Aktif',
                  activeProducts.toString(),
                  Icons.check_circle_outline,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Draft',
                  draftProducts.toString(),
                  Icons.edit_outlined,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: (index) => _filterByStatus(_getStatusFromIndex(index)),
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Aktif'),
          Tab(text: 'Draft'),
          Tab(text: 'Review'),
          Tab(text: 'Nonaktif'),
        ],
      ),
    );
  }

  Widget _buildTabBarView(SellerProductsState sellerProducts) {
    if (sellerProducts.isLoading && sellerProducts.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sellerProducts.error != null && sellerProducts.products.isEmpty) {
      return _buildErrorState(sellerProducts.error!);
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildProductsList(sellerProducts, null),
        _buildProductsList(sellerProducts, ProductStatus.active),
        _buildProductsList(sellerProducts, ProductStatus.draft),
        _buildProductsList(sellerProducts, ProductStatus.pendingReview),
        _buildProductsList(sellerProducts, ProductStatus.inactive),
      ],
    );
  }

  Widget _buildProductsList(
      SellerProductsState sellerProducts, ProductStatus? status) {
    var products = sellerProducts.products;
    if (status != null) {
      products = products.where((p) => p.status == status).toList();
    }

    if (products.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () => _refreshProducts(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: products.length + (sellerProducts.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= products.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final product = products[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductCard(
              product: product,
              onTap: () => _navigateToEditProduct(product),
              onStatusChange: (newStatus) =>
                  _changeProductStatus(product, newStatus),
              onDelete: () => _deleteProduct(product),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ProductStatus? status) {
    String title;
    String subtitle;
    IconData icon;

    switch (status) {
      case ProductStatus.active:
        title = 'Belum Ada Produk Aktif';
        subtitle = 'Produk aktif akan muncul di marketplace';
        icon = Icons.store_outlined;
        break;
      case ProductStatus.draft:
        title = 'Belum Ada Draft';
        subtitle = 'Simpan produk sebagai draft untuk dilanjutkan nanti';
        icon = Icons.edit_outlined;
        break;
      case ProductStatus.pendingReview:
        title = 'Tidak Ada Produk Review';
        subtitle = 'Produk yang menunggu persetujuan admin';
        icon = Icons.pending_outlined;
        break;
      case ProductStatus.inactive:
        title = 'Tidak Ada Produk Nonaktif';
        subtitle = 'Produk yang dinonaktifkan tidak tampil di marketplace';
        icon = Icons.visibility_off_outlined;
        break;
      default:
        title = 'Belum Ada Produk';
        subtitle = 'Mulai dengan menambahkan produk pertama Anda';
        icon = Icons.inventory_2_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Tambah Produk',
              onPressed: () => _navigateToAddProduct(),
              icon: Icons.add,
              variant: CustomButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Produk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Coba Lagi',
              onPressed: () => _refreshProducts(),
              variant: CustomButtonVariant.outlined,
            ),
          ],
        ),
      ),
    );
  }

  ProductStatus? _getStatusFromIndex(int index) {
    switch (index) {
      case 0:
        return null; // All products
      case 1:
        return ProductStatus.active;
      case 2:
        return ProductStatus.draft;
      case 3:
        return ProductStatus.pendingReview;
      case 4:
        return ProductStatus.inactive;
      default:
        return null;
    }
  }

  void _filterByStatus(ProductStatus? status) {
    final auth = ref.read(authProvider);
    if (auth.user != null) {
      ref
          .read(sellerProductsProvider(auth.user!.id).notifier)
          .filterByStatus(status);
    }
  }

  Future<void> _refreshProducts() async {
    final auth = ref.read(authProvider);
    if (auth.user != null) {
      await ref.read(sellerProductsProvider(auth.user!.id).notifier).refresh();
    }
  }

  void _navigateToAddProduct() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const ProductFormScreen(),
      ),
    )
        .then((result) {
      if (result is Product) {
        final auth = ref.read(authProvider);
        if (auth.user != null) {
          ref
              .read(sellerProductsProvider(auth.user!.id).notifier)
              .addProduct(result);
        }
        SnackbarUtils.showSuccess(context, 'Produk berhasil ditambahkan');
      }
    });
  }

  void _navigateToEditProduct(Product product) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    )
        .then((result) {
      if (result is Product) {
        final auth = ref.read(authProvider);
        if (auth.user != null) {
          ref
              .read(sellerProductsProvider(auth.user!.id).notifier)
              .updateProduct(result);
        }
        SnackbarUtils.showSuccess(context, 'Produk berhasil diperbarui');
      }
    });
  }

  void _changeProductStatus(Product product, ProductStatus newStatus) {
    // TODO: Implement status change via API
    final auth = ref.read(authProvider);
    if (auth.user != null) {
      final updatedProduct = product.copyWith(status: newStatus);
      ref
          .read(sellerProductsProvider(auth.user!.id).notifier)
          .updateProduct(updatedProduct);
      SnackbarUtils.showSuccess(context, 'Status produk berhasil diubah');
    }
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text(
            'Yakin ingin menghapus "${product.name}"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final auth = ref.read(authProvider);
              if (auth.user != null) {
                ref
                    .read(sellerProductsProvider(auth.user!.id).notifier)
                    .removeProduct(product.id);
              }
              SnackbarUtils.showSuccess(context, 'Produk berhasil dihapus');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
