import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import '../theme/colors.dart';

/// A rounded text field with a tinted "well" at its head holding the leading
/// icon. White surface, a hairline edge that lifts into brand purple on focus.
///
/// Public API is unchanged apart from the optional [dense] flag, so every
/// screen already using it picks up the new finish for free.
class CustomTextField extends StatefulWidget {
  /// Shown above the field. Leave null for a hint-only field.
  final String? labelText;

  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? suffixIcon;

  /// Drawn in the tinted well at the head of the field.
  final IconData? prefixIcon;

  final String? Function(String?)? validator;

  /// Trims the vertical padding, for screens that are short on room.
  final bool dense;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.labelText,
    this.obscureText = false,
    this.controller,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.dense = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  static const double _radius = 18;

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
    final pad = widget.dense ? 9.0 : 15.0;
    final fontSize = widget.dense ? 14.5 : 16.0;

    final field = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: _focused ? AppColors.secondary : AppColors.hairline,
          width: _focused ? 1.6 : 1.2,
        ),
        boxShadow: [
          if (_focused)
            const BoxShadow(
              color: Color(0x336D28D9),
              blurRadius: 14,
              offset: Offset(0, 4),
            )
          else
            const BoxShadow(
              color: Color(0x0F6D28D9),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
        ],
      ),
      // Stretching the row is what lets the icon well run the full height of
      // the field, error message and all.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.prefixIcon != null)
              Container(
                width: widget.dense ? 44 : 48,
                decoration: const BoxDecoration(
                  color: AppColors.fieldWell,
                  border: Border(
                    right: BorderSide(color: AppColors.hairline),
                  ),
                ),
                child: Icon(
                  widget.prefixIcon,
                  size: widget.dense ? 20 : 22,
                  color: AppColors.secondary,
                ),
              ),
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                validator: widget.validator,
                style: AppTypography.inputText.copyWith(fontSize: fontSize),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTypography.inputHint.copyWith(
                    fontSize: fontSize,
                  ),
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(14, pad, 4, pad),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  errorStyle: const TextStyle(fontSize: 11.5, height: 1.1),
                  suffixIcon: widget.suffixIcon,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 46,
                    minHeight: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.labelText == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.labelText!, style: AppTypography.inputLabel),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
