import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_style.dart';

extension CommonPaddingHorizontal on Widget {
  Widget screenPadding() {
    return paddingOnly(left: 16, right: 16);
  }
}

Widget commonHeadingText(String text) {
  return Text(text, style: AppTextStyles.heading4);
}

Widget buildChip({IconData? icon, String? label, Function()? onTap}) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: GestureDetector(
      onTap: onTap ?? () {},
      child: Chip(
        avatar: Icon(icon, size: 18, color: AppColors.colorWhite),

        label: Text(label ?? "", style: AppTextStyles.bodyMedium),
        color: WidgetStatePropertyAll(AppColors.colorBgGray02),

        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      ),
    ),
  );
}

Widget buildActionBox({IconData? icon, String? assetPath, required String label}) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.colorBgChipContainer, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // If asset exists → show Image else show Icon
          assetPath != null ? Image.asset(assetPath, height: 26, width: 26) : Icon(icon, size: 26, color: Colors.white),

          const SizedBox(height: 8),

          Text(label, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium500),
        ],
      ),
    ),
  );
}

Widget commonCircleButton({
  required VoidCallback onTap,

  required String iconPath,
  double iconSize = 15,
  double padding = 10,
  Color bgColor = AppColors.colorBgChipContainer,
  Color iconColor = AppColors.colorWhite,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: Image.asset(iconPath, height: iconSize, color: iconColor),
    ),
  );
}
