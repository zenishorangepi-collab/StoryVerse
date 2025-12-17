import 'package:flutter/material.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_style.dart';

class CommonElevatedButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  final Color? backgroundColor;
  final double radius;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final IconData? icon;
  final bool isDark;
  final BorderSide side;

  const CommonElevatedButton({
    super.key,
    required this.title,
    this.onTap,
    this.backgroundColor,
    this.radius = 8,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.textStyle,
    this.icon,
    this.side = BorderSide.none,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? (isDark ? AppColors.colorBlack : AppColors.colorWhite),
        overlayColor: AppColors.colorTransparent,

        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: side),
      ),
      onPressed: onTap ?? () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 30, color: isDark ? AppColors.colorWhite : AppColors.colorBlack),
          Text(title, style: textStyle ?? (isDark ? AppTextStyles.button16WhiteBold : AppTextStyles.button16BlackBold)),
        ],
      ),
    );
  }
}
