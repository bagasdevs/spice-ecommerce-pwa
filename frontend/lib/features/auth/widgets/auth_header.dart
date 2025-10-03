import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? logo;
  final bool showLogo;
  final Color? titleColor;
  final Color? subtitleColor;
  final TextAlign textAlign;

  const AuthHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.logo,
    this.showLogo = true,
    this.titleColor,
    this.subtitleColor,
    this.textAlign = TextAlign.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showLogo) ...[
          logo ?? _buildDefaultLogo(),
          const SizedBox(height: 32),
        ],
        Text(
          title,
          textAlign: textAlign,
          style: AppTextStyles.displaySmall.copyWith(
            color: titleColor ?? AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: textAlign,
            style: AppTextStyles.bodyLarge.copyWith(
              color: subtitleColor ?? AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.agriculture,
        color: AppColors.textInverse,
        size: 40,
      ),
    );
  }
}

class WelcomeHeader extends StatelessWidget {
  final String name;
  final String? subtitle;
  final Widget? avatar;

  const WelcomeHeader({
    Key? key,
    required this.name,
    this.subtitle,
    this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        avatar ?? _buildDefaultAvatar(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang,',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                name,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textInverse,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class BrandHeader extends StatelessWidget {
  final String? tagline;
  final bool showTagline;

  const BrandHeader({
    Key? key,
    this.tagline,
    this.showTagline = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo with gradient background
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.agriculture,
            color: AppColors.textInverse,
            size: 50,
          ),
        ),
        const SizedBox(height: 24),

        // App name
        Text(
          'Spice Farmers Connect',
          textAlign: TextAlign.center,
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),

        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            tagline ?? 'Platform Rempah Indonesia dengan AI',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class ProgressHeader extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final List<String>? stepTitles;

  const ProgressHeader({
    Key? key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    this.stepTitles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Progress indicator
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep - 1;

            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index < totalSteps - 1 ? 8 : 0,
                ),
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? AppColors.primary
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        // Step counter
        Text(
          'Langkah $currentStep dari $totalSteps',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        // Step title if provided
        if (stepTitles != null && currentStep <= stepTitles!.length) ...[
          const SizedBox(height: 4),
          Text(
            stepTitles![currentStep - 1],
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class ErrorHeader extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;

  const ErrorHeader({
    Key? key,
    required this.title,
    required this.message,
    this.icon,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            icon ?? Icons.error_outline,
            color: AppColors.error,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}

class SuccessHeader extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onContinue;
  final String? continueText;

  const SuccessHeader({
    Key? key,
    required this.title,
    required this.message,
    this.icon,
    this.onContinue,
    this.continueText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            icon ?? Icons.check_circle_outline,
            color: AppColors.success,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (onContinue != null) ...[
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.arrow_forward),
            label: Text(continueText ?? 'Lanjutkan'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}
