import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

import '../../auth/providers/auth_provider.dart';
import '../../products/providers/product_provider.dart';
import '../../products/models/product_model.dart';
import 'product_form_screen.dart';
import 'seller_products_screen.dart';
import 'seller_orders_screen.dart';
import 'seller_analytics_screen.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/recent_orders_widget.dart';
import '../widgets/product_performance_widget.dart';

class SellerDashboardScreen extends ConsumerStatefulWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SellerDashboardScreen> createState() =>
      _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends ConsumerState<SellerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    final auth = ref.read(authProvider);
    if (auth.user != null) {
      ref.read(sellerProductsProvider(auth.user!.id).notifier).loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final sellerProducts =
        ref.watch(sellerProductsProvider(auth.user?.id ?? ''));

    return Scaffold(
      appBar: _buildAppBar(),
      body: _selectedIndex == 0
          ? _buildDashboardBody(sellerProducts)
          : _buildSelectedScreen(),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? _buildFloatingActionButton()
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Dashboard Petani',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                // TODO: Navigate to profile
                break;
              case 'settings':
                // TODO: Navigate to settings
                break;
              case 'help':
                // TODO: Navigate to help
                break;
              case 'logout':
                ref.read(authProvider.notifier).logout();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  const Text('Profil'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  const Text('Pengaturan'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help_outline, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  const Text('Bantuan'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: AppColors.error),
                  const SizedBox(width: 12),
                  Text('Keluar', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardBody(SellerProductsState sellerProducts) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(sellerProductsProvider(ref.read(authProvider).user!.id)
                .notifier)
            .refresh();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildOverviewCards(sellerProducts),
            const SizedBox(height: 24),
            _buildSalesChart(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
            const SizedBox(height: 24),
            _buildProductPerformance(sellerProducts),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final auth = ref.watch(authProvider);
    final now = DateTime.now();
    final hour = now.hour;

    String greeting;
    if (hour < 12) {
      greeting = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting,',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            auth.user?.name ?? 'Petani',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mari kelola bisnis rempah Anda hari ini',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.add_box_outlined,
                title: 'Tambah Produk',
                subtitle: 'Produk baru',
                color: AppColors.success,
                onTap: () => _navigateToAddProduct(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.insights_outlined,
                title: 'Analisis AI',
                subtitle: 'Harga optimal',
                color: AppColors.info,
                onTap: () => _showAiInsightDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(SellerProductsState sellerProducts) {
    final activeProducts = sellerProducts.products
        .where((p) => p.status == ProductStatus.active)
        .length;
    final totalProducts = sellerProducts.products.length;
    final lowStockProducts =
        sellerProducts.products.where((p) => p.isLowStock).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            DashboardCard(
              title: 'Produk Aktif',
              value: activeProducts.toString(),
              subtitle: 'dari $totalProducts produk',
              icon: Icons.inventory_2_outlined,
              color: AppColors.success,
            ),
            DashboardCard(
              title: 'Penjualan Bulan Ini',
              value: 'Rp 0', // TODO: Get from API
              subtitle: '+0% dari bulan lalu',
              icon: Icons.trending_up,
              color: AppColors.primary,
            ),
            DashboardCard(
              title: 'Pesanan Baru',
              value: '0', // TODO: Get from API
              subtitle: 'Perlu diproses',
              icon: Icons.shopping_bag_outlined,
              color: AppColors.warning,
            ),
            DashboardCard(
              title: 'Stok Menipis',
              value: lowStockProducts.toString(),
              subtitle: 'Produk perlu restock',
              icon: Icons.warning_amber_outlined,
              color: AppColors.error,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Penjualan (7 Hari Terakhir)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Sen',
                          'Sel',
                          'Rab',
                          'Kam',
                          'Jum',
                          'Sab',
                          'Min'
                        ];
                        return Text(
                          days[value.toInt() % 7],
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 1),
                      const FlSpot(2, 4),
                      const FlSpot(3, 2),
                      const FlSpot(4, 5),
                      const FlSpot(5, 3),
                      const FlSpot(6, 6),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 2; // Orders tab
                });
              },
              child: Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const RecentOrdersWidget(),
      ],
    );
  }

  Widget _buildProductPerformance(SellerProductsState sellerProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Performa Produk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1; // Products tab
                });
              },
              child: Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ProductPerformanceWidget(
            products: sellerProducts.products.take(3).toList()),
      ],
    );
  }

  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 1:
        return const SellerProductsScreen();
      case 2:
        return const SellerOrdersScreen();
      case 3:
        return const SellerAnalyticsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Produk',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Pesanan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Analisis',
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedIndex == 0 || _selectedIndex == 1) {
      return FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Tambah Produk', style: TextStyle(color: Colors.white)),
      );
    }
    return null;
  }

  void _navigateToAddProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProductFormScreen(),
      ),
    );
  }

  void _showAiInsightDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analisis AI'),
        content: const Text(
          'Fitur analisis AI akan membantu Anda menentukan harga optimal untuk produk rempah berdasarkan kondisi pasar terkini.\n\n'
          'Tambahkan produk baru untuk mendapatkan rekomendasi harga dari AI.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToAddProduct();
            },
            child: const Text('Tambah Produk'),
          ),
        ],
      ),
    );
  }
}
