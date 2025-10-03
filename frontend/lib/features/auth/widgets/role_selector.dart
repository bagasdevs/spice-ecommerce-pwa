import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class RoleSelector extends StatelessWidget {
  final String? selectedRole;
  final ValueChanged<String> onRoleSelected;
  final bool enabled;

  const RoleSelector({
    Key? key,
    this.selectedRole,
    required this.onRoleSelected,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Peran Anda',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...AppConstants.userRoles.entries.map((role) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RoleCard(
              roleKey: role.key,
              roleTitle: role.value,
              description: _getRoleDescription(role.key),
              icon: _getRoleIcon(role.key),
              isSelected: selectedRole == role.key,
              onTap: enabled ? () => onRoleSelected(role.key) : null,
            ),
          );
        }).toList(),
      ],
    );
  }

  String _getRoleDescription(String roleKey) {
    switch (roleKey) {
      case 'SELLER':
        return 'Jual hasil panen rempah Anda dengan harga terbaik menggunakan prediksi AI';
      case 'BUYER':
        return 'Beli rempah berkualitas langsung dari petani dengan harga kompetitif';
      case 'ADMIN':
        return 'Kelola platform dan pantau aktivitas perdagangan rempah';
      default:
        return '';
    }
  }

  IconData _getRoleIcon(String roleKey) {
    switch (roleKey) {
      case 'SELLER':
        return Icons.agriculture;
      case 'BUYER':
        return Icons.shopping_cart;
      case 'ADMIN':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }
}

class RoleCard extends StatelessWidget {
  final String roleKey;
  final String roleTitle;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const RoleCard({
    Key? key,
    required this.roleKey,
    required this.roleTitle,
    required this.description,
    required this.icon,
    required this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.textInverse : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleTitle,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.textInverse,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SimpleRoleSelector extends StatelessWidget {
  final String? selectedRole;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const SimpleRoleSelector({
    Key? key,
    this.selectedRole,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      decoration: InputDecoration(
        labelText: 'Peran',
        prefixIcon: Icon(
          Icons.person_outline,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: AppConstants.userRoles.entries.map((role) {
        return DropdownMenuItem<String>(
          value: role.key,
          child: Row(
            children: [
              Icon(
                _getRoleIcon(role.key),
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(role.value),
            ],
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Silakan pilih peran Anda';
        }
        return null;
      },
    );
  }

  IconData _getRoleIcon(String roleKey) {
    switch (roleKey) {
      case 'SELLER':
        return Icons.agriculture;
      case 'BUYER':
        return Icons.shopping_cart;
      case 'ADMIN':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }
}

class RoleBadge extends StatelessWidget {
  final String role;
  final Color? backgroundColor;
  final Color? textColor;

  const RoleBadge({
    Key? key,
    required this.role,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roleData = _getRoleData(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? roleData['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            roleData['icon'],
            size: 14,
            color: textColor ?? roleData['color'],
          ),
          const SizedBox(width: 4),
          Text(
            AppConstants.userRoles[role] ?? role,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor ?? roleData['color'],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getRoleData(String role) {
    switch (role) {
      case 'SELLER':
        return {
          'icon': Icons.agriculture,
          'color': AppColors.success,
        };
      case 'BUYER':
        return {
          'icon': Icons.shopping_cart,
          'color': AppColors.info,
        };
      case 'ADMIN':
        return {
          'icon': Icons.admin_panel_settings,
          'color': AppColors.warning,
        };
      default:
        return {
          'icon': Icons.person,
          'color': AppColors.textSecondary,
        };
    }
  }
}
