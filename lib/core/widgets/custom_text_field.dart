import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// A glossy, rounded text field used across the app. Soft white surface, a
/// hairline edge that lifts into a brand-purple glow on focus, and an optional
/// leading icon with a divider. Public API is unchanged so every screen that
/// already uses it picks up the new finish for free.
class CustomTextField extends StatefulWidget {
  /// Shown above the field. Leave null for a hint-only field.
  final String? labelText;

  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? suffixIcon;

  /// Drawn inside the field, with a divider after it.
  final IconData? prefixIcon;

  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.labelText,
    this.obscureText = false,
    this.controller,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus != _focused) {
        setState(() => _focused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: AppColors.cardSheen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? AppColors.primary : AppColors.hairline,
          width: _focused ? 1.6 : 1,
        ),
        boxShadow: [
          if (_focused)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            )
          else
            const BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        validator: widget.validator,
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hintText,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          suffixIcon: widget.suffixIcon,
          prefixIcon: widget.prefixIcon == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: _focused
                            ? AppColors.primary
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 1,
                        height: 22,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
        ),
      ),
    );

    if (widget.labelText == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText!,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
