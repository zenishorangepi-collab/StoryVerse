import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_style.dart';

extension CommonPaddingHorizontal on Widget {
  Widget screenPadding() {
    return paddingOnly(left: 16, right: 16);
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
          color: WidgetStatePropertyAll(AppColors.colorBgWhite02),

          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        ),
      ),
    );
  }

  Widget commonCircleButton({
    required VoidCallback onTap,

    required String iconPath,
    double iconSize = 15,
    double padding = 10,
    Color bgColor = const Color(0x1AFFFFFF),
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
}
