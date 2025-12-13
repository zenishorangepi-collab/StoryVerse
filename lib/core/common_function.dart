import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_style.dart';

extension CommonPaddingHorizontal on Widget {
  Widget screenPadding() {
    return paddingOnly(left: 20, right: 20);
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
        avatar: icon == null ? null : Icon(icon, size: 18, color: AppColors.colorWhite).paddingOnly(left: 5),

        label: Text(label ?? "", style: AppTextStyles.bodyMedium500, overflow: TextOverflow.ellipsis),
        color: WidgetStatePropertyAll(AppColors.colorBgChipContainer),

        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
    ),
  );
}

Widget buildActionBox({IconData? icon, String? assetPath, required String label, double? iconSize}) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.colorBgChipContainer, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // If asset exists → show Image else show Icon
          assetPath != null ? Image.asset(assetPath, height: iconSize ?? 26, width: iconSize ?? 26) : Icon(icon, size: 26, color: Colors.white),

          const SizedBox(height: 8),

          Text(label, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium500),
        ],
      ),
    ),
  );
}

Widget commonCircleButton({
  required VoidCallback onTap,

  String? iconPath,
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
      child: iconPath == null ? Icon(Icons.arrow_back_ios) : Image.asset(iconPath, height: iconSize, color: iconColor),
    ),
  );
}
