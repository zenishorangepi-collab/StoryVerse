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

  const CommonElevatedButton({
    super.key,
    required this.title,
    this.onTap,
    this.backgroundColor = AppColors.colorWhite,
    this.radius = 8,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.textStyle,
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
      child: Text(title, style: textStyle ?? AppTextStyles.buttonTextBlack),
    );
  }
}
