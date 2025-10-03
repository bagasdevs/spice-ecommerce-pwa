import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';

class AppRouter {
  // Route names
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String sellerDashboard = '/seller-dashboard';
  static const String buyerHome = '/buyer-home';
  static const String adminDashboard = '/admin-dashboard';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const LoginScreen());

      case register:
        return _buildRoute(const RegisterScreen());

      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen());

      case sellerDashboard:
        return _buildRoute(const SellerDashboardScreen());

      case buyerHome:
        return _buildRoute(const BuyerHomeScreen());

      case adminDashboard:
        return _buildRoute(const AdminDashboardScreen());

      default:
        return _buildRoute(
          const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }

  // Helper method to build route with slide transition
  static PageRouteBuilder _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Navigate and clear stack
  static void navigateAndClearStack(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );
  }

  // Navigate and replace
  static void navigateAndReplace(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  // Navigate with arguments
  static void navigateWithArgs(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Pop until route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  // Can pop
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  // Pop
  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }
}

// Temporary placeholder screens
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: const Center(
        child: Text(
          'Register Screen\n(Under Development)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: const Center(
        child: Text(
          'Forgot Password Screen\n(Under Development)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Petani'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 80,
              color: Color(0xFF2E7D32),
            ),
            SizedBox(height: 20),
            Text(
              'Selamat Datang, Petani!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Dashboard petani sedang dalam pengembangan',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

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
