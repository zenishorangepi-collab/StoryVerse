import 'package:flutter/material.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_style.dart';

class CommonElevatedButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  final Color backgroundColor;
  final double radius;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final IconData? icon;

  const CommonElevatedButton({
    super.key,
    required this.title,
    this.onTap,
    this.backgroundColor = AppColors.colorWhite,
    this.radius = 8,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.textStyle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        overlayColor: AppColors.colorTransparent,

        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      onPressed: onTap ?? () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [if (icon != null) Icon(icon, size: 30, color: AppColors.colorBlack), Text(title, style: textStyle ?? AppTextStyles.buttonTextBlack)],
      ),
    );
  }
}
