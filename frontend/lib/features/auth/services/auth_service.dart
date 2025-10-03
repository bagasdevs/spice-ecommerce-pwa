import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final String baseUrl = AppConstants.baseUrl;

  // HTTP client with default headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, String> _headersWithAuth(String token) => {
        ..._headers,
        'Authorization': 'Bearer $token',
      };

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConstants.authEndpoint}/login'),
            headers: _headers,
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(AppConstants.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: data['message'],
          user: data['user'] != null ? User.fromJson(data['user']) : null,
          token: data['token'],
        );
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  // Register
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    String? address,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConstants.authEndpoint}/register'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'phone': phone,
              'role': role,
              'address': address,
            }),
          )
          .timeout(AppConstants.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: data['message'],
          user: data['user'] != null ? User.fromJson(data['user']) : null,
          token: data['token'],
        );
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  // Forgot password
  Future<AuthResponse> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConstants.authEndpoint}/forgot-password'),
            headers: _headers,
            body: jsonEncode({
              'email': email,
            }),
          )
          .timeout(AppConstants.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: data['message'],
        );
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to send reset email',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  // Reset password
  Future<AuthResponse> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConstants.authEndpoint}/reset-password'),
            headers: _headers,
            body: jsonEncode({
              'token': token,
              'newPassword': newPassword,
            }),
          )
          .timeout(AppConstants.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: data['message'],
        );
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to reset password',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  // Validate token
  Future<bool> validateToken(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl${AppConstants.authEndpoint}/validate'),
            headers: _headersWithAuth(token),
          )
          .timeout(AppConstants.connectTimeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get user profile
  Future<AuthResponse> getUserProfile(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl${AppConstants.authEndpoint}/profile'),
            headers: _headersWithAuth(token),
          )
          .timeout(AppConstants.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: data['message'],
          user: data['user'] != null ? User.fromJson(data['user']) : null,
        );
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  // Update profile
  Future<AuthResponse> updateProfile({
    required String token,
    required String name,
    required String phone,
    String? address,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl${AppConstants.authEndpoint}/profile'),
            headers: _headersWithAuth(token),
            body: jsonEncode({
              'name': name,
              'phone': phone,
              'address': address,
            }),
          )
          .timeout(AppConstants.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: data['message'],
          user: data['user'] != null ? User.fromJson(data['user']) : null,
        );
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  // Change password
  Future<AuthResponse> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl${AppConstants.authEndpoint}/change-password'),
            headers: _headersWithAuth(token),
            body: jsonEncode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(AppConstants.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: data['message'],
        );
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to change password',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  // Refresh token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConstants.authEndpoint}/refresh'),
            headers: _headers,
            body: jsonEncode({
              'refreshToken': refreshToken,
            }),
          )
          .timeout(AppConstants.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: data['message'],
          token: data['token'],
        );
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to refresh token',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  // Logout
  Future<void> logout(String token) async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl${AppConstants.authEndpoint}/logout'),
            headers: _headersWithAuth(token),
          )
          .timeout(AppConstants.connectTimeout);
    } catch (e) {
      // Ignore errors on logout
    }
  }

  // Verify email
  Future<AuthResponse> verifyEmail({
    required String token,
    required String verificationCode,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConstants.authEndpoint}/verify-email'),
            headers: _headers,
            body: jsonEncode({
              'token': token,
              'verificationCode': verificationCode,
            }),
          )
          .timeout(AppConstants.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: data['message'],
        );
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to verify email',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  // Check email availability
  Future<bool> checkEmailAvailability(String email) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '$baseUrl${AppConstants.authEndpoint}/check-email?email=$email'),
            headers: _headers,
          )
          .timeout(AppConstants.connectTimeout);

      final data = jsonDecode(response.body);
      return data['available'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Check phone availability
  Future<bool> checkPhoneAvailability(String phone) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '$baseUrl${AppConstants.authEndpoint}/check-phone?phone=$phone'),
            headers: _headers,
          )
          .timeout(AppConstants.connectTimeout);

      final data = jsonDecode(response.body);
      return data['available'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Delete account
  Future<AuthResponse> deleteAccount({
    required String token,
    required String password,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl${AppConstants.authEndpoint}/account'),
            headers: _headersWithAuth(token),
            body: jsonEncode({
              'password': password,
            }),
          )
          .timeout(AppConstants.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: data['message'],
        );
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to delete account',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return AppConstants.networkError;
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timeout. Please try again.';
    } else if (error.toString().contains('FormatException')) {
      return AppConstants.serverError;
    } else {
      return error.toString().replaceAll('Exception: ', '');
    }
  }
}
