import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/seller/screens/seller_dashboard_screen.dart' as seller;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure URL strategy for web
  usePathUrlStrategy();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SpiceFarmersApp(),
    ),
  );
}

class SpiceFarmersApp extends ConsumerWidget {
  const SpiceFarmersApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      onGenerateRoute: AppRouter.generateRoute,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authState.user != null) {
      // Navigate based on user role
      switch (authState.user!.role) {
        case 'SELLER':
          return const seller.SellerDashboardScreen();
        case 'BUYER':
          return const BuyerHomeScreen();
        case 'ADMIN':
          return const AdminDashboardScreen();
        default:
          return const LoginScreen();
      }
    }

    return const LoginScreen();
  }
}

// Temporary screens until proper screens are implemented

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace Rempah'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              size: 80,
              color: Color(0xFF2E7D32),
            ),
            SizedBox(height: 20),
            Text(
              'Selamat Datang, Pembeli!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Marketplace sedang dalam pengembangan',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Color(0xFF2E7D32),
            ),
            SizedBox(height: 20),
            Text(
              'Selamat Datang, Admin!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Dashboard admin sedang dalam pengembangan',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
