import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:utsav_interview/core/common_color.dart';

enum AppFontType { inter, openSans, libreBaskerville }

AppFontType currentAudioTextFonts = AppFontType.inter;
double dCurrentAudioTextSize = 16;

///-------------------------------------------------------
/// Pattern :- {type}{Size}{Color}{Weight}
///-------------------------------------------------------
class AppTextStyles {
  /// AudioText Fonts Only
  static TextStyle audioTextFontOnly({double? fontSize, FontWeight? fontWeight, Color? color, double height = 1.3}) {
    switch (currentAudioTextFonts) {
      case AppFontType.inter:
        return GoogleFonts.inter(fontSize: dCurrentAudioTextSize, fontWeight: fontWeight, color: color, height: height);

      case AppFontType.openSans:
        return GoogleFonts.openSans(fontSize: dCurrentAudioTextSize, fontWeight: fontWeight, color: color, height: height);

      case AppFontType.libreBaskerville:
        return GoogleFonts.libreBaskerville(fontSize: dCurrentAudioTextSize, fontWeight: fontWeight, color: color, height: height);
    }
  }

  /// WholeApp Font
  static TextStyle wholeAppFont({double? fontSize, FontWeight? fontWeight, Color? color, double height = 1.3}) {
    return GoogleFonts.inter(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height);
  }

  /// HEADLINES
  static TextStyle heading30WhiteBold = wholeAppFont(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.colorWhite);
  static TextStyle heading28WhiteBold = wholeAppFont(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.colorWhite);
  static TextStyle heading28BlackBold = wholeAppFont(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.colorBlack);

  //24
  static TextStyle heading24WhiteMedium = wholeAppFont(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.colorWhite);

  //22
  static TextStyle body22GreyMedium = wholeAppFont(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.colorAppBar);

  //20
  static TextStyle heading20WhiteSemiBold = wholeAppFont(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.colorWhite);
  static TextStyle heading20WhiteRegular = wholeAppFont(fontSize: 20, color: AppColors.colorWhite);
  static TextStyle heading20BlackBold = wholeAppFont(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.colorBlack);

  //18
  static TextStyle heading18WhiteSemiBold = wholeAppFont(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.colorWhite);
  static TextStyle heading18WhiteRegular = wholeAppFont(fontSize: 18, fontWeight: FontWeight.normal, color: AppColors.colorWhite);
  static TextStyle heading18WhiteMedium = wholeAppFont(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.colorWhite);

  static TextStyle heading18BlackMedium = wholeAppFont(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.colorBlack);

  static TextStyle heading18GreyBold = wholeAppFont(fontSize: 18, color: AppColors.colorGrey, fontWeight: FontWeight.bold);

  static TextStyle errorText18 = wholeAppFont(
    fontSize: 18,
    // fontWeight: FontWeight.w600,
    color: AppColors.colorRed,
  );

  /// BODY TEXT
  // 16
  static TextStyle body16WhiteBold = wholeAppFont(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.colorWhite);
  static TextStyle body16WhiteMedium = wholeAppFont(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.colorWhite);
  static TextStyle body16BlackMedium = wholeAppFont(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.colorBlack);
  static TextStyle body16WhiteLight = wholeAppFont(fontSize: 16, fontWeight: FontWeight.w300, color: AppColors.colorWhite);
  static TextStyle body16WhiteRegular = wholeAppFont(fontSize: 16, color: AppColors.colorWhite);

  //14
  static TextStyle body14Regular = wholeAppFont(fontSize: 14, color: AppColors.colorWhite);
  static TextStyle body14BlackRegular = wholeAppFont(fontSize: 14, color: AppColors.colorBlack);
  static TextStyle body14WhiteMedium = wholeAppFont(fontSize: 14, color: AppColors.colorWhite, fontWeight: FontWeight.w500);
  static TextStyle body14BlackMedium = wholeAppFont(fontSize: 14, color: AppColors.colorBlack, fontWeight: FontWeight.w500);
  static TextStyle body14WhiteBold = wholeAppFont(fontSize: 14, color: AppColors.colorWhite, fontWeight: FontWeight.bold);

  static TextStyle body12Regular = wholeAppFont(fontSize: 12, color: AppColors.colorWhite);
  static TextStyle body12BlackMedium = wholeAppFont(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.colorBlack);

  // grey 20
  static TextStyle body20GreyMedium = wholeAppFont(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.colorGrey);

  //16
  static TextStyle body16GreyBold = wholeAppFont(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.colorGrey);
  static TextStyle body16GreyMedium = wholeAppFont(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.colorGrey);
  static TextStyle body16GreyRegular = wholeAppFont(fontSize: 16, color: AppColors.colorGrey);

  //14
  static TextStyle body14GreyBold = wholeAppFont(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.colorGrey);
  static TextStyle body14GreySemiBold = wholeAppFont(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.colorGrey);
  static TextStyle body16GreySemiBold = wholeAppFont(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.colorGrey);
  static TextStyle body14GreyRegular = wholeAppFont(fontSize: 14, color: AppColors.colorGrey);

  //12
  static TextStyle body12GreyRegular = wholeAppFont(fontSize: 12, color: AppColors.colorGrey);

  // Red 14
  static TextStyle body14RedRegular = wholeAppFont(fontSize: 14, color: AppColors.colorRed);
  static TextStyle body14RedBold = wholeAppFont(fontSize: 14, color: AppColors.colorRed, fontWeight: FontWeight.bold);
  static TextStyle body16RedBold = wholeAppFont(fontSize: 16, color: AppColors.colorRed, fontWeight: FontWeight.bold);

  /// BUTTON TEXT
  // 18
  static TextStyle button18BlackBold = wholeAppFont(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.colorBlack);
  static TextStyle button18WhiteBold = wholeAppFont(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.colorWhite);

  //16
  static TextStyle button16WhiteBold = wholeAppFont(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.colorWhite);
  static TextStyle button16BlackBold = wholeAppFont(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.colorBlack);

  // Blue 16
  static TextStyle button16BlueBold = wholeAppFont(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue);

  // 14
  static TextStyle button14BlackBold = wholeAppFont(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.colorBlack);

  /// TabBar Text
  static final tabTextSelectedWhite = wholeAppFont(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.colorWhite);
  static final tabTextSelectedBlack = wholeAppFont(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.colorBlack);
  static final tabTextSelectedGrey = wholeAppFont(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.colorGrey);

  /// Audio Text Use Only
  static TextStyle body16WhiteMediumLibre = GoogleFonts.libreBaskerville(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.colorWhite);
  static TextStyle body12WhiteMediumLibre = GoogleFonts.libreBaskerville(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.colorWhite);
  static TextStyle body16WhiteLightLibre = GoogleFonts.libreBaskerville(fontSize: 16, fontWeight: FontWeight.w300, color: AppColors.colorWhite);
  static TextStyle body16WhiteMediumOpenSans = GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.colorWhite);
  static TextStyle body16WhiteLightOpenSans = GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w300, color: AppColors.colorWhite);

  /// CAPTION
  // static TextStyle caption = GoogleFonts.robotoSlab(
  //   fontSize: 11,
  //   color: Get.isDarkMode ? AppColors.colorGrey : AppColors.darkGrey,
  // );
}
