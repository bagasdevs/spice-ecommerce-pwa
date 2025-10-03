import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? suffixText;
  final bool isRequired;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final BorderRadius? borderRadius;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final bool dense;
  final FloatingLabelBehavior floatingLabelBehavior;

  const CustomTextField({
    Key? key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.suffixText,
    this.isRequired = false,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.focusNode,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.dense = false,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
  }) : super(key: key);

  // Named constructors for common use cases
  const CustomTextField.email({
    Key? key,
    this.controller,
    this.label = 'Email',
    this.hint = 'Masukkan alamat email',
    this.helperText,
    this.errorText,
    this.suffixText,
    this.isRequired = false,
    this.prefixIcon = Icons.email_outlined,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.focusNode,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.dense = false,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
  })  : obscureText = false,
        keyboardType = TextInputType.emailAddress,
        textInputAction = TextInputAction.next,
        maxLines = 1,
        maxLength = null,
        textCapitalization = TextCapitalization.none,
        super(key: key);

  const CustomTextField.password({
    Key? key,
    this.controller,
    this.label = 'Password',
    this.hint = 'Masukkan password',
    this.helperText,
    this.errorText,
    this.suffixText,
    this.isRequired = false,
    this.prefixIcon = Icons.lock_outline,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.focusNode,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.dense = false,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
  })  : obscureText = true,
        keyboardType = TextInputType.visiblePassword,
        textInputAction = TextInputAction.done,
        maxLines = 1,
        maxLength = null,
        textCapitalization = TextCapitalization.none,
        super(key: key);

  CustomTextField.phone({
    Key? key,
    this.controller,
    this.label = 'Nomor Telepon',
    this.hint = 'Masukkan nomor telepon',
    this.helperText,
    this.errorText,
    this.suffixText,
    this.isRequired = false,
    this.prefixIcon = Icons.phone_outlined,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.focusNode,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.textAlign = TextAlign.start,
    this.dense = false,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
  })  : obscureText = false,
        keyboardType = TextInputType.phone,
        textInputAction = TextInputAction.next,
        maxLines = 1,
        maxLength = null,
        inputFormatters = [FilteringTextInputFormatter.digitsOnly],
        textCapitalization = TextCapitalization.none,
        super(key: key);

  const CustomTextField.multiline({
    Key? key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.suffixText,
    this.isRequired = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 3,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.focusNode,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.sentences,
    this.textAlign = TextAlign.start,
    this.dense = false,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
  })  : obscureText = false,
        keyboardType = TextInputType.multiline,
        textInputAction = TextInputAction.newline,
        super(key: key);

  CustomTextField.number({
    Key? key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.suffixText,
    this.isRequired = false,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.focusNode,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.textAlign = TextAlign.start,
    this.dense = false,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
  })  : obscureText = false,
        keyboardType = TextInputType.number,
        textInputAction = TextInputAction.done,
        maxLines = 1,
        maxLength = null,
        inputFormatters = [FilteringTextInputFormatter.digitsOnly],
        textCapitalization = TextCapitalization.none,
        super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(12);
    final effectiveContentPadding = widget.contentPadding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    final effectiveFillColor = widget.fillColor ?? AppColors.surface;
    final effectiveBorderColor = widget.borderColor ?? AppColors.divider;
    final effectiveFocusedBorderColor =
        widget.focusedBorderColor ?? AppColors.primary;

    Widget? suffixIcon = widget.suffixIcon;
    if (widget.obscureText && suffixIcon == null) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
        ),
        onPressed: _toggleObscureText,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          onTap: widget.onTap,
          onEditingComplete: widget.onEditingComplete,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          textAlign: widget.textAlign,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            labelText: widget.isRequired && widget.label != null
                ? '${widget.label} *'
                : widget.label,
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            suffixText: widget.suffixText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color:
                        _hasFocus ? AppColors.primary : AppColors.textSecondary,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: effectiveFillColor,
            contentPadding: effectiveContentPadding,
            isDense: widget.dense,
            floatingLabelBehavior: widget.floatingLabelBehavior,
            border: OutlineInputBorder(
              borderRadius: effectiveBorderRadius,
              borderSide: BorderSide(color: effectiveBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: effectiveBorderRadius,
              borderSide: BorderSide(color: effectiveBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: effectiveBorderRadius,
              borderSide:
                  BorderSide(color: effectiveFocusedBorderColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: effectiveBorderRadius,
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: effectiveBorderRadius,
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: effectiveBorderRadius,
              borderSide:
                  BorderSide(color: AppColors.disabled.withOpacity(0.5)),
            ),
            labelStyle: AppTextStyles.inputLabel.copyWith(
              color: _hasFocus ? AppColors.primary : AppColors.textSecondary,
            ),
            hintStyle: AppTextStyles.inputHint,
            helperStyle: AppTextStyles.caption,
            errorStyle: AppTextStyles.errorText,
            counterStyle: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}

// Specialized text fields for specific use cases
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const SearchTextField({
    Key? key,
    this.controller,
    this.hint = 'Cari...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hint: hint,
      prefixIcon: Icons.search,
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
            )
          : null,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
    );
  }
}

class PriceTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PriceTextField({
    Key? key,
    this.controller,
    this.label = 'Harga',
    this.hint = 'Masukkan harga',
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.attach_money,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class WeightTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const WeightTextField({
    Key? key,
    this.controller,
    this.label = 'Berat (kg)',
    this.hint = 'Masukkan berat',
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.scale,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: validator,
      onChanged: onChanged,
    );
  }
}
