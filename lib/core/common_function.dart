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

  Widget buildChip(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        avatar: Icon(icon, size: 18, color: AppColors.colorWhite),

        label: Text(label, style: AppTextStyles.bodyMedium),
        color: WidgetStatePropertyAll(AppColors.colorBgWhite02),

        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      ),
    );
  }
}
