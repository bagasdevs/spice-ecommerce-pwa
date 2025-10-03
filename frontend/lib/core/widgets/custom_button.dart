import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum CustomButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  danger,
  success,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledColor;
  final EdgeInsetsGeometry? padding;
  final Size? size;
  final BorderRadius? borderRadius;
  final IconData? icon;
  final Widget? child;
  final ButtonType type;
  final CustomButtonVariant? variant;
  final double? elevation;
  final BorderSide? side;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledColor,
    this.padding,
    this.size,
    this.borderRadius,
    this.icon,
    this.child,
    this.type = ButtonType.elevated,
    this.variant,
    this.elevation,
    this.side,
  }) : super(key: key);

  const CustomButton.primary({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding,
    this.size,
    this.borderRadius,
    this.icon,
    this.child,
    this.elevation,
  })  : backgroundColor = AppColors.primary,
        foregroundColor = AppColors.textInverse,
        disabledColor = AppColors.disabled,
        type = ButtonType.elevated,
        variant = CustomButtonVariant.primary,
        side = null,
        super(key: key);

  const CustomButton.secondary({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding,
    this.size,
    this.borderRadius,
    this.icon,
    this.child,
    this.elevation,
  })  : backgroundColor = AppColors.secondary,
        foregroundColor = AppColors.textInverse,
        disabledColor = AppColors.disabled,
        type = ButtonType.elevated,
        variant = CustomButtonVariant.secondary,
        side = null,
        super(key: key);

  const CustomButton.outlined({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.foregroundColor = AppColors.primary,
    this.disabledColor = AppColors.disabled,
    this.padding,
    this.size,
    this.borderRadius,
    this.icon,
    this.child,
    this.side = const BorderSide(color: AppColors.primary, width: 2),
  })  : type = ButtonType.outlined,
        variant = CustomButtonVariant.outlined,
        elevation = null,
        super(key: key);

  const CustomButton.text({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.foregroundColor = AppColors.primary,
    this.disabledColor = AppColors.disabled,
    this.padding,
    this.size,
    this.borderRadius,
    this.icon,
    this.child,
  })  : type = ButtonType.text,
        variant = CustomButtonVariant.text,
        elevation = null,
        side = null,
        super(key: key);

  const CustomButton.danger({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding,
    this.size,
    this.borderRadius,
    this.icon,
    this.child,
    this.elevation,
  })  : backgroundColor = AppColors.error,
        foregroundColor = AppColors.textInverse,
        disabledColor = AppColors.disabled,
        type = ButtonType.elevated,
        variant = CustomButtonVariant.danger,
        side = null,
        super(key: key);

  const CustomButton.success({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding,
    this.size,
    this.borderRadius,
    this.icon,
    this.child,
    this.elevation,
  })  : backgroundColor = AppColors.success,
        foregroundColor = AppColors.textInverse,
        disabledColor = AppColors.disabled,
        type = ButtonType.elevated,
        variant = CustomButtonVariant.success,
        side = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isEnabled && !isLoading) ? onPressed : null;
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    // Override colors based on variant
    Color? effectiveBackgroundColor = backgroundColor;
    Color? effectiveForegroundColor = foregroundColor;
    BorderSide? effectiveSide = side;
    ButtonType effectiveType = type;

    if (variant != null) {
      switch (variant!) {
        case CustomButtonVariant.primary:
          effectiveBackgroundColor = AppColors.primary;
          effectiveForegroundColor = AppColors.textInverse;
          effectiveType = ButtonType.elevated;
          break;
        case CustomButtonVariant.secondary:
          effectiveBackgroundColor = AppColors.secondary;
          effectiveForegroundColor = AppColors.textInverse;
          effectiveType = ButtonType.elevated;
          break;
        case CustomButtonVariant.outlined:
          effectiveBackgroundColor = null;
          effectiveForegroundColor = AppColors.primary;
          effectiveSide = const BorderSide(color: AppColors.primary, width: 2);
          effectiveType = ButtonType.outlined;
          break;
        case CustomButtonVariant.text:
          effectiveBackgroundColor = null;
          effectiveForegroundColor = AppColors.primary;
          effectiveType = ButtonType.text;
          break;
        case CustomButtonVariant.danger:
          effectiveBackgroundColor = AppColors.error;
          effectiveForegroundColor = AppColors.textInverse;
          effectiveType = ButtonType.elevated;
          break;
        case CustomButtonVariant.success:
          effectiveBackgroundColor = AppColors.success;
          effectiveForegroundColor = AppColors.textInverse;
          effectiveType = ButtonType.elevated;
          break;
      }
    }

    Widget buttonChild = _buildButtonContent(effectiveForegroundColor);

    switch (effectiveType) {
      case ButtonType.elevated:
        return SizedBox(
          width: size?.width,
          height: size?.height,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: effectiveBackgroundColor ?? AppColors.primary,
              foregroundColor:
                  effectiveForegroundColor ?? AppColors.textInverse,
              disabledBackgroundColor: disabledColor ?? AppColors.disabled,
              disabledForegroundColor: AppColors.textSecondary,
              padding: effectivePadding,
              elevation: elevation ?? 2,
              shape: RoundedRectangleBorder(
                borderRadius: effectiveBorderRadius,
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonType.outlined:
        return SizedBox(
          width: size?.width,
          height: size?.height,
          child: OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: effectiveBackgroundColor,
              foregroundColor: effectiveForegroundColor ?? AppColors.primary,
              disabledForegroundColor: disabledColor ?? AppColors.disabled,
              padding: effectivePadding,
              side: effectiveSide ??
                  const BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: effectiveBorderRadius,
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonType.text:
        return SizedBox(
          width: size?.width,
          height: size?.height,
          child: TextButton(
            onPressed: effectiveOnPressed,
            style: TextButton.styleFrom(
              backgroundColor: effectiveBackgroundColor,
              foregroundColor: effectiveForegroundColor ?? AppColors.primary,
              disabledForegroundColor: disabledColor ?? AppColors.disabled,
              padding: effectivePadding,
              shape: RoundedRectangleBorder(
                borderRadius: effectiveBorderRadius,
              ),
            ),
            child: buttonChild,
          ),
        );
    }
  }

  Widget _buildButtonContent(Color? effectiveForegroundColor) {
    if (child != null) {
      return child!;
    }

    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                effectiveForegroundColor ?? AppColors.textInverse,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading...',
            style: AppTextStyles.button.copyWith(
              color: effectiveForegroundColor ?? AppColors.textInverse,
            ),
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: effectiveForegroundColor ?? AppColors.textInverse,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.button.copyWith(
              color: effectiveForegroundColor ?? AppColors.textInverse,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: AppTextStyles.button.copyWith(
        color: effectiveForegroundColor ?? AppColors.textInverse,
      ),
    );
  }
}

enum ButtonType {
  elevated,
  outlined,
  text,
}

// Specialized buttons for common use cases
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Size? size;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton.primary(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      size: size,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Size? size;

  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton.outlined(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      size: size,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Size? size;

  const DangerButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton.danger(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      size: size,
    );
  }
}

class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Size? size;

  const SuccessButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton.success(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      size: size,
    );
  }
}
