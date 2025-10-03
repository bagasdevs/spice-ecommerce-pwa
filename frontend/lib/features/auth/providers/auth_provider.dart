import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Auth state class
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final SharedPreferences _prefs;

  AuthNotifier(this._authService, this._prefs) : super(const AuthState()) {
    _checkAuthStatus();
  }

  // Check if user is authenticated on app start
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final token = _prefs.getString(AppConstants.authTokenKey);
      final userDataJson = _prefs.getString(AppConstants.userDataKey);

      if (token != null && userDataJson != null) {
        // Validate token with server
        final isValid = await _authService.validateToken(token);

        if (isValid) {
          final user = User.fromJsonString(userDataJson);
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
        } else {
          // Token is invalid, clear stored data
          await _clearStoredAuth();
          state = state.copyWith(isLoading: false);
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to check authentication status',
        isLoading: false,
      );
    }
  }

  // Login method
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success) {
        final user = response.user!;
        final token = response.token!;

        // Store auth data
        await _prefs.setString(AppConstants.authTokenKey, token);
        await _prefs.setString(AppConstants.userDataKey, user.toJsonString());

        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );

        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Login failed',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Register method
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Registration failed',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Forgot password method
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.forgotPassword(email);

      if (response.success) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to send reset email',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Reset password method
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      if (response.success) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to reset password',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Update profile method
  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? address,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = _prefs.getString(AppConstants.authTokenKey);
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _authService.updateProfile(
        token: token,
        name: name,
        phone: phone,
        address: address,
      );

      if (response.success) {
        final updatedUser = response.user!;

        // Update stored user data
        await _prefs.setString(
          AppConstants.userDataKey,
          updatedUser.toJsonString(),
        );

        state = state.copyWith(
          user: updatedUser,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to update profile',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Change password method
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = _prefs.getString(AppConstants.authTokenKey);
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _authService.changePassword(
        token: token,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to change password',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final token = _prefs.getString(AppConstants.authTokenKey);
      if (token != null) {
        await _authService.logout(token);
      }
    } catch (e) {
      // Continue with logout even if server call fails
    } finally {
      await _clearStoredAuth();
      state = const AuthState();
    }
  }

  // Clear stored authentication data
  Future<void> _clearStoredAuth() async {
    await _prefs.remove(AppConstants.authTokenKey);
    await _prefs.remove(AppConstants.userDataKey);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;

    try {
      final token = _prefs.getString(AppConstants.authTokenKey);
      if (token == null) return;

      final response = await _authService.getUserProfile(token);

      if (response.success) {
        final updatedUser = response.user!;

        // Update stored user data
        await _prefs.setString(
          AppConstants.userDataKey,
          updatedUser.toJsonString(),
        );

        state = state.copyWith(user: updatedUser);
      }
    } catch (e) {
      // Silently fail - don't update error state for background refresh
    }
  }

  // Get current auth token
  String? get authToken => _prefs.getString(AppConstants.authTokenKey);
}

// Provider instances
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(authService, prefs);
});

// Helper providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
