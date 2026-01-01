import 'package:flutter/material.dart';
import 'package:utsav_interview/core/common_color.dart';

class CommonTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscure;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;
  final bool enabled;
  final Color? fillColor;
  final double radius;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final double height;

  const CommonTextFormField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.prefix,
    this.suffix,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines = 1,
    this.radius = 12,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onTap,
    this.fillColor,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: minLines,
        enabled: enabled,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        cursorColor: AppColors.colorWhite,
        style: const TextStyle(fontSize: 16, color: AppColors.colorWhite),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.colorGrey),
          labelStyle: TextStyle(color: AppColors.colorGrey),
          prefixIcon: prefix,
          suffixIcon: suffix,

          filled: true,
          fillColor: fillColor ?? AppColors.colorTransparent,

          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),

          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: AppColors.colorBgWhite10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: AppColors.colorBgWhite10)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: AppColors.colorRed)),
        ),
      ),
    );
  }
}
