import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

Widget commonChip({IconData? icon, String? label, Function()? onTap}) {
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
  VoidCallback? onTap,
  String? iconPath,
  double iconSize = 15,
  double padding = 10,
  double leftPadding = 8,
  bool isBackButton = true,
  Widget? icon,
  Color bgColor = AppColors.colorBgWhite10,
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
                  ? Icon(Icons.arrow_back_ios, color: iconColor, size: iconSize).paddingOnly(left: leftPadding)
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
            ? Icon(icon, color: iconColor ?? AppColors.colorWhite, size: imageHeight ?? 22)
            : Image.asset(assetPath, height: imageHeight ?? 22, color: iconColor),
    title: Text(title, style: style ?? AppTextStyles.body16WhiteRegular),
    subtitle: subtitle == null ? null : Text(subtitle ?? "", style: subtitleStyle ?? AppTextStyles.body14GreyRegular),
    onTap: onTap,
    trailing: trailing,
  );
}

String formatDate(String date) {
  final DateTime parsedDate = DateTime.parse(date);
  return DateFormat('dd MMM, yyyy').format(parsedDate);
}

String formatReadableLength(String rawTime) {
  List<String> parts = rawTime.split(':');

  // mm:ss format → Xm Ys
  if (parts.length == 2) {
    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);

    String result = "";

    if (minutes > 0) result += "${minutes}m ";
    if (seconds > 0) result += "${seconds}s";

    return result.trim();
  }

  // hh:mm:ss format → Hh MMm SSs
  if (parts.length == 3) {
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    String result = "";

    if (hours > 0) result += "${hours}h ";
    if (minutes > 0) result += "${minutes}m ";
    if (seconds > 0) result += "${seconds}s";

    return result.trim();
  }

  return rawTime;
}

commonActionButton({Color? color, IconData? icon, String? label, VoidCallback? onTap}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: color),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.colorWhite),
            const SizedBox(height: 5),
            Text(label ?? "", textAlign: TextAlign.center, style: AppTextStyles.body14WhiteMedium),
          ],
        ),
      ),
    ),
  );
}
