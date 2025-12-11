import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:utsav_interview/core/common_color.dart';

class AppTextStyles {
  /// HEADLINES
  static TextStyle heading1 = GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.colorWhite);

  static TextStyle heading2 = GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.colorWhite);

  static TextStyle heading3 = GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.colorWhite);

  static TextStyle heading4 = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.colorWhite);
  static TextStyle heading4Normal18White = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.normal, color: AppColors.colorWhite);
  static TextStyle heading4500White18 = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.colorWhite);
  static TextStyle heading4Grey18 = GoogleFonts.inter(fontSize: 18, color: AppColors.colorGrey, fontWeight: FontWeight.bold);

  static TextStyle errorText18 = GoogleFonts.inter(
    fontSize: 18,
    // fontWeight: FontWeight.w600,
    color: AppColors.colorRed,
  );

  /// BODY TEXT
  static TextStyle bodyLarge = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.colorWhite);
  static TextStyle bodyLarge16white500 = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.colorWhite);
  static TextStyle bodyLargeWhite16 = GoogleFonts.inter(fontSize: 16, color: AppColors.colorWhite);

  static TextStyle bodyMedium = GoogleFonts.inter(fontSize: 14, color: AppColors.colorWhite);
  static TextStyle bodyMedium500 = GoogleFonts.inter(fontSize: 14, color: AppColors.colorWhite, fontWeight: FontWeight.w500);
  static TextStyle bodyMediumBold = GoogleFonts.inter(fontSize: 14, color: AppColors.colorWhite, fontWeight: FontWeight.bold);

  static TextStyle bodySmall = GoogleFonts.inter(fontSize: 12, color: AppColors.colorWhite);

  // grey
  static TextStyle bodyLargeGray = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.colorGrey);
  static TextStyle bodyMediumGrey = GoogleFonts.inter(fontSize: 14, color: AppColors.colorGrey);
  static TextStyle bodySmallGrey = GoogleFonts.inter(fontSize: 12, color: AppColors.colorGrey);

  // Red
  static TextStyle bodyMediumRed = GoogleFonts.inter(fontSize: 14, color: AppColors.colorRed);
  static TextStyle bodyMediumRedBold = GoogleFonts.inter(fontSize: 14, color: AppColors.colorRed, fontWeight: FontWeight.bold);

  /// BUTTON TEXT
  static TextStyle buttonTextWhite = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.colorWhite);
  static TextStyle buttonTextBlack = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.colorBlack);
  static TextStyle buttonTextBlack14 = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.colorBlack);

  /// TabBar Text
  static final tabTextSelectedWhite = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white);
  static final tabTextSelectedGrey = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.colorGrey);

  /// CAPTION
  // static TextStyle caption = GoogleFonts.robotoSlab(
  //   fontSize: 11,
  //   color: Get.isDarkMode ? AppColors.colorGrey : AppColors.darkGrey,
  // );
}
