import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? address;
  final String? profileImage;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.city,
    this.province,
    this.postalCode,
    this.address,
    this.profileImage,
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    // Handle profile data if exists
    final profile = json['profile'] as Map<String, dynamic>?;

    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      city: json['city'] as String?,
      province: json['province'] as String?,
      postalCode: json['postalCode'] as String?,
      address: profile?['address'] as String?,
      profileImage: profile?['avatar'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Factory constructor from JSON string
  factory User.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return User.fromJson(json);
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'address': address,
      'profileImage': profileImage,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Copy with method
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? city,
    String? province,
    String? postalCode,
    String? address,
    String? profileImage,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters for role checking
  bool get isSeller => role == 'SELLER';
  bool get isBuyer => role == 'BUYER';
  bool get isAdmin => role == 'ADMIN';

  // Get role display name
  String get roleDisplayName {
    switch (role) {
      case 'SELLER':
        return 'Petani';
      case 'BUYER':
        return 'Pembeli';
      case 'ADMIN':
        return 'Admin';
      default:
        return role;
    }
  }

  // Get initials for avatar
  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    } else {
      return 'U';
    }
  }

  // Check if profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        city != null &&
        city!.isNotEmpty &&
        province != null &&
        province!.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.role == role &&
        other.city == city &&
        other.province == province &&
        other.postalCode == postalCode &&
        other.address == address &&
        other.profileImage == profileImage &&
        other.isActive == isActive &&
        other.isVerified == isVerified &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      email,
      phone,
      role,
      city,
      province,
      postalCode,
      address,
      profileImage,
      isActive,
      isVerified,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, role: $role}';
  }
}

// Auth response model
class AuthResponse {
  final bool success;
  final String? message;
  final User? user;
  final String? token;
  final String? refreshToken;

  const AuthResponse({
    required this.success,
    this.message,
    this.user,
    this.token,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'token': token,
      'refreshToken': refreshToken,
    };
  }
}

// User profile update request
class UserProfileUpdateRequest {
  final String name;
  final String phone;
  final String? address;
  final String? profileImage;

  const UserProfileUpdateRequest({
    required this.name,
    required this.phone,
    this.address,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
    };
  }
}

// Password change request
class PasswordChangeRequest {
  final String currentPassword;
  final String newPassword;

  const PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}

// User registration request
class UserRegistrationRequest {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String role;
  final String? address;

  const UserRegistrationRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      'address': address,
    };
  }
}

// Login request
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// Forgot password request
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

// Reset password request
class ResetPasswordRequest {
  final String token;
  final String newPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'newPassword': newPassword,
    };
  }
}
