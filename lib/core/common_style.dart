import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:utsav_interview/core/common_color.dart';

class AppTextStyles {
  /// HEADLINES
  static TextStyle heading1 = GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.colorWhite);

  static TextStyle heading2 = GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.colorWhite);

  static TextStyle heading3 = GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.colorWhite);

  static TextStyle heading4 = GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.colorWhite);
  static TextStyle errorText18 = GoogleFonts.roboto(
    fontSize: 18,
    // fontWeight: FontWeight.w600,
    color: AppColors.colorRed,
  );

  /// BODY TEXT
  static TextStyle bodyLarge = GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.colorWhite);

  static TextStyle bodyMedium = GoogleFonts.roboto(fontSize: 14, color: AppColors.colorWhite);
  static TextStyle bodyMediumGrey = GoogleFonts.roboto(fontSize: 14, color: AppColors.colorGrey);
  static TextStyle bodyMediumGrey16 = GoogleFonts.roboto(fontSize: 16, color: AppColors.colorGrey);
  static TextStyle bodyMediumWhite16 = GoogleFonts.roboto(fontSize: 16, color: AppColors.colorWhite, fontWeight: FontWeight.bold);

  static TextStyle bodySmall = GoogleFonts.roboto(fontSize: 12, color: AppColors.colorWhite);

  /// BUTTON TEXT
  static TextStyle buttonTextWhite = GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.colorWhite);
  static TextStyle buttonTextBlack = GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.colorBlack);

  /// TabBar Text
  static final tabTextSelectedWhite = GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white);
  static final tabTextSelectedGrey = GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.colorGrey);

  /// CAPTION
  // static TextStyle caption = GoogleFonts.robotoSlab(
  //   fontSize: 11,
  //   color: Get.isDarkMode ? AppColors.colorGrey : AppColors.darkGrey,
  // );
}
