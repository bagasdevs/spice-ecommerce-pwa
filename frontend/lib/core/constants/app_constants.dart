class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:3001/api';
  // For production: 'https://your-api-domain.vercel.app/api'

  // App Information
  static const String appName = 'Spice Farmers Connect';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Platform e-commerce rempah Indonesia dengan AI';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String sellerEndpoint = '/seller';
  static const String buyerEndpoint = '/buyer';
  static const String adminEndpoint = '/admin';
  static const String productsEndpoint = '/products';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Pagination
  static const int defaultPageSize = 12;
  static const int maxPageSize = 50;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 1000;

  // Indonesian Phone Number Regex
  static const String phoneRegex = r'^(\+62|62|0)[0-9]{9,13}$';

  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Spice Types
  static const Map<String, String> spiceTypes = {
    'JAHE': 'Jahe',
    'KUNYIT': 'Kunyit',
    'LENGKUAS': 'Lengkuas',
    'KENCUR': 'Kencur',
    'TEMULAWAK': 'Temulawak',
    'SERAI': 'Serai',
    'DAUN_JERUK': 'Daun Jeruk',
    'CABE_RAWIT': 'Cabe Rawit',
    'KEMIRI': 'Kemiri',
    'PALA': 'Pala',
    'CENGKEH': 'Cengkeh',
    'KAYU_MANIS': 'Kayu Manis',
    'MERICA': 'Merica',
    'JINTAN': 'Jintan',
    'KETUMBAR': 'Ketumbar',
    'KAPULAGA': 'Kapulaga',
    'BUNGA_LAWANG': 'Bunga Lawang',
    'OTHER': 'Lainnya',
  };

  // Quality Grades
  static const Map<String, String> qualityGrades = {
    'A_PREMIUM': 'Grade A (Premium)',
    'B_STANDARD': 'Grade B (Standard)',
    'C_ECONOMY': 'Grade C (Ekonomi)',
  };

  // Transaction Status
  static const Map<String, String> transactionStatus = {
    'PENDING': 'Menunggu',
    'PAID': 'Dibayar',
    'PROCESSING': 'Diproses',
    'SHIPPED': 'Dikirim',
    'DELIVERED': 'Diterima',
    'CANCELLED': 'Dibatalkan',
    'REFUNDED': 'Dikembalikan',
  };

  // Payment Status
  static const Map<String, String> paymentStatus = {
    'PENDING': 'Menunggu',
    'SUCCESS': 'Berhasil',
    'FAILED': 'Gagal',
    'CANCELLED': 'Dibatalkan',
  };

  // User Roles
  static const Map<String, String> userRoles = {
    'SELLER': 'Petani',
    'BUYER': 'Pembeli',
    'ADMIN': 'Admin',
  };

  // Currency Format
  static const String currencySymbol = 'Rp';
  static const String currencyFormat = '#,##0';

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';
  static const String timeFormat = 'HH:mm';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // PWA Configuration
  static const String manifestPath = '/manifest.json';
  static const String serviceWorkerPath = '/flutter_service_worker.js';

  // Firebase Configuration (if needed)
  static const String firebaseApiKey = '';
  static const String firebaseProjectId = '';

  // Analytics
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;

  // Feature Flags
  static const bool enableDarkMode = true;
  static const bool enableNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableAIFeatures = true;

  // Social Links
  static const String websiteUrl = 'https://spicefarmers.id';
  static const String supportEmail = 'support@spicefarmers.id';
  static const String phoneSupport = '+62811234567';

  // Error Messages
  static const String networkError = 'Koneksi internet bermasalah';
  static const String serverError = 'Server sedang bermasalah';
  static const String unknownError = 'Terjadi kesalahan tidak dikenal';
  static const String authError = 'Sesi Anda telah berakhir';
  static const String validationError = 'Data tidak valid';
}
