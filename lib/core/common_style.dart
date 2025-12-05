import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:utsav_interview/core/common_color.dart';

class AppTextStyles {
  /// HEADLINES
  static TextStyle heading1 = GoogleFonts.robotoSlab(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.colorWhite,
  );

  static TextStyle heading2 = GoogleFonts.robotoSlab(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.colorWhite,
  );

  static TextStyle heading3 = GoogleFonts.robotoSlab(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.colorWhite,
  );

  static TextStyle heading4 = GoogleFonts.robotoSlab(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.colorWhite,
  );
  static TextStyle errorText18 = GoogleFonts.robotoSlab(
    fontSize: 18,
    // fontWeight: FontWeight.w600,
    color: AppColors.colorRed,
  );

  /// BODY TEXT
  static TextStyle bodyLarge = GoogleFonts.robotoSlab(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.colorWhite,
  );

  static TextStyle bodyMedium = GoogleFonts.robotoSlab(
    fontSize: 14,
    color: AppColors.colorWhite,
  );
  static TextStyle bodyMediumGrey = GoogleFonts.robotoSlab(
    fontSize: 14,
    color: AppColors.colorGrey,
  );
  static TextStyle bodyMediumGrey16 = GoogleFonts.robotoSlab(
    fontSize: 16,
    color: AppColors.colorGrey,
  );

  static TextStyle bodySmall = GoogleFonts.robotoSlab(
    fontSize: 12,
    color: AppColors.colorWhite,
  );

  /// BUTTON TEXT
  static TextStyle buttonTextWhite = GoogleFonts.robotoSlab(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.colorWhite,
  );  static TextStyle buttonTextBlack = GoogleFonts.robotoSlab(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.colorBlack,
  );

  /// TabBar Text
  static final tabTextSelectedWhite = GoogleFonts.robotoSlab(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static final tabTextSelectedGrey = GoogleFonts.robotoSlab(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.colorGrey,
  );

  /// CAPTION
  // static TextStyle caption = GoogleFonts.robotoSlab(
  //   fontSize: 11,
  //   color: Get.isDarkMode ? AppColors.colorGrey : AppColors.darkGrey,
  // );
}
