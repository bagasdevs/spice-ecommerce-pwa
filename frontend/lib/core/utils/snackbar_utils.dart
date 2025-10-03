import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SnackbarUtils {
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
      duration: duration,
      action: action,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
      duration: duration,
      action: action,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_outlined,
      duration: duration,
      action: action,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message,
      backgroundColor: AppColors.info,
      icon: Icons.info_outline,
      duration: duration,
      action: action,
    );
  }

  static void showCustom(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message,
      backgroundColor: backgroundColor ?? AppColors.textPrimary,
      textColor: textColor ?? AppColors.textInverse,
      icon: icon,
      duration: duration,
      action: action,
    );
  }

  static void _showSnackbar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    // Remove any existing snackbar
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor ?? AppColors.textInverse,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.snackbar.copyWith(
                color: textColor ?? AppColors.textInverse,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      action: action,
      elevation: 6,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void hideCurrentSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  static void hideAllSnackbars(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  // Predefined actions
  static SnackBarAction retryAction(VoidCallback onPressed) {
    return SnackBarAction(
      label: 'Coba Lagi',
      textColor: AppColors.textInverse,
      onPressed: onPressed,
    );
  }

  static SnackBarAction undoAction(VoidCallback onPressed) {
    return SnackBarAction(
      label: 'Batalkan',
      textColor: AppColors.textInverse,
      onPressed: onPressed,
    );
  }

  static SnackBarAction dismissAction() {
    return SnackBarAction(
      label: 'Tutup',
      textColor: AppColors.textInverse,
      onPressed: () {}, // Empty action, just dismisses
    );
  }

  static SnackBarAction viewAction(VoidCallback onPressed) {
    return SnackBarAction(
      label: 'Lihat',
      textColor: AppColors.textInverse,
      onPressed: onPressed,
    );
  }

  // Network specific snackbars
  static void showNetworkError(BuildContext context) {
    showError(
      context,
      'Koneksi internet bermasalah. Periksa koneksi Anda.',
      duration: const Duration(seconds: 5),
    );
  }

  static void showServerError(BuildContext context) {
    showError(
      context,
      'Server sedang bermasalah. Silakan coba lagi nanti.',
      duration: const Duration(seconds: 4),
    );
  }

  static void showTimeoutError(BuildContext context) {
    showError(
      context,
      'Permintaan timeout. Periksa koneksi internet Anda.',
      duration: const Duration(seconds: 4),
    );
  }

  // Auth specific snackbars
  static void showLoginSuccess(BuildContext context, String userName) {
    showSuccess(
      context,
      'Selamat datang, $userName!',
    );
  }

  static void showLogoutSuccess(BuildContext context) {
    showInfo(
      context,
      'Anda telah berhasil keluar.',
    );
  }

  static void showAuthError(BuildContext context) {
    showError(
      context,
      'Sesi Anda telah berakhir. Silakan masuk kembali.',
      duration: const Duration(seconds: 4),
    );
  }

  // Form validation snackbars
  static void showValidationError(BuildContext context, String field) {
    showWarning(
      context,
      '$field tidak valid. Periksa kembali input Anda.',
    );
  }

  static void showRequiredFieldError(BuildContext context, String field) {
    showWarning(
      context,
      '$field wajib diisi.',
    );
  }

  // Success operations
  static void showSaveSuccess(BuildContext context) {
    showSuccess(
      context,
      'Data berhasil disimpan.',
    );
  }

  static void showUpdateSuccess(BuildContext context) {
    showSuccess(
      context,
      'Data berhasil diperbarui.',
    );
  }

  static void showDeleteSuccess(BuildContext context) {
    showSuccess(
      context,
      'Data berhasil dihapus.',
    );
  }

  static void showUploadSuccess(BuildContext context) {
    showSuccess(
      context,
      'File berhasil diunggah.',
    );
  }

  // Loading operations
  static void showProcessing(BuildContext context, String operation) {
    showInfo(
      context,
      '$operation sedang diproses...',
      duration: const Duration(seconds: 2),
    );
  }

  // E-commerce specific
  static void showAddToCartSuccess(BuildContext context, String productName) {
    showSuccess(
      context,
      '$productName ditambahkan ke keranjang.',
    );
  }

  static void showOrderSuccess(BuildContext context, String orderId) {
    showSuccess(
      context,
      'Pesanan $orderId berhasil dibuat.',
      duration: const Duration(seconds: 4),
    );
  }

  static void showPaymentSuccess(BuildContext context) {
    showSuccess(
      context,
      'Pembayaran berhasil diproses.',
      duration: const Duration(seconds: 4),
    );
  }

  static void showPaymentFailed(BuildContext context) {
    showError(
      context,
      'Pembayaran gagal. Silakan coba lagi.',
      duration: const Duration(seconds: 4),
    );
  }

  // Offline/Online status
  static void showOfflineWarning(BuildContext context) {
    showWarning(
      context,
      'Anda sedang offline. Beberapa fitur mungkin tidak tersedia.',
      duration: const Duration(seconds: 5),
    );
  }

  static void showOnlineInfo(BuildContext context) {
    showInfo(
      context,
      'Koneksi internet tersambung kembali.',
      duration: const Duration(seconds: 2),
    );
  }
}
