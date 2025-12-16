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
  return Text(text, style: AppTextStyles.heading20WhiteSemiBold);
}

Widget buildChip({IconData? icon, String? label, Function()? onTap}) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),

    child: GestureDetector(
      onTap: onTap ?? () {},
      child: Chip(
        avatar: icon == null ? null : Icon(icon, size: 18, color: AppColors.colorWhite).paddingOnly(left: 5),

        label: Text(label ?? "", style: AppTextStyles.body14WhiteMedium, overflow: TextOverflow.ellipsis),
        color: WidgetStatePropertyAll(AppColors.colorChipBackground),

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
      decoration: BoxDecoration(color: AppColors.colorChipBackground, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // If asset exists → show Image else show Icon
          assetPath != null ? Image.asset(assetPath, height: iconSize ?? 26, width: iconSize ?? 26) : Icon(icon, size: 26, color: Colors.white),

          const SizedBox(height: 8),

          Text(label, textAlign: TextAlign.center, style: AppTextStyles.body14WhiteMedium),
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
  bool isBackButton = true,
  Widget? icon,
  Color bgColor = AppColors.colorChipBackground,
  Color iconColor = AppColors.colorWhite,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child:
          iconPath == null
              ? isBackButton
                  ? Icon(Icons.arrow_back_ios, color: iconColor).paddingOnly(left: 8)
                  : icon
              : Image.asset(iconPath, height: iconSize, color: iconColor),
    ),
  );
}

Widget commonListTile({
  String? assetPath,
  required String title,
  String? subtitle,
  VoidCallback? onTap,
  IconData? icon,
  double? imageHeight,
  TextStyle? style,
  TextStyle? subtitleStyle,
  Color? iconColor,
  bool isLeading = true,
  Widget? trailing,
  Color? tileColor,
}) {
  return ListTile(
    tileColor: tileColor,
    minTileHeight: 50,
    splashColor: AppColors.colorTransparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
    leading:
        !isLeading
            ? null
            : assetPath == null
            ? Icon(icon, color: iconColor ?? AppColors.colorWhite)
            : Image.asset(assetPath ?? "", height: imageHeight ?? 22, color: iconColor),
    title: Text(title, style: style ?? AppTextStyles.body16WhiteRegular),
    subtitle: subtitle == null ? null : Text(subtitle ?? "", style: subtitleStyle ?? AppTextStyles.body14GreyRegular),
    onTap: onTap,
    trailing: trailing,
  );
}
