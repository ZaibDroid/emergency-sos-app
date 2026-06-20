import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      maxLines: maxLines,
    );
  }
}
