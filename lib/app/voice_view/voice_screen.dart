import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:utsav_interview/app/sound_spaces_view/sound_spaces_controller.dart';
import 'package:utsav_interview/app/voice_view/voice_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/common_textfield.dart';

import '../../core/common_function.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VoiceController>(
      init: VoiceController(),
      builder: (controller) {
        return Scaffold(
          body:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 45),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: Text(CS.vSelectVoice, style: AppTextStyles.heading2)),

                      Row(
                        spacing: 10,
                        children: [
                          commonCircleButton(onTap: () {}, iconPath: CS.icSearch),
                          commonCircleButton(
                            onTap: () {
                              _openSettingSheet(context);
                            },
                            iconPath: CS.icSettings,
                          ),
                          commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        buildChip(icon: Icons.access_time_filled, label: CS.vRecents),
                        buildChip(icon: Icons.favorite, label: CS.vFavorites),
                        buildChip(icon: Icons.explore, label: CS.vExplore),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {},
                          child: ListTile(
                            minTileHeight: 35,

                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),

                            leading: CircleAvatar(
                              radius: 20,

                              backgroundColor: Colors.white24,
                              child: ClipOval(child: Image.network("https://i.pravatar.cc/100", fit: BoxFit.cover, height: 40, width: 40)),
                            ),
                            title: Text("Turn off soundscapces", style: AppTextStyles.bodyLarge),
                            subtitle: Text("subtitle", style: AppTextStyles.bodyMediumGrey),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min, // REQUIRED
                              children: const [
                                Icon(Icons.check_circle_rounded, color: Colors.white),
                                SizedBox(width: 15),
                                Icon(Icons.favorite_border, color: Colors.white),
                              ],
                            ),
                          ).paddingOnly(bottom: 2),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    spacing: 15,
                    children: [
                      Expanded(
                        child: CommonElevatedButton(title: CS.vReset, backgroundColor: AppColors.colorBgWhite02, textStyle: AppTextStyles.buttonTextWhite),
                      ),
                      Expanded(child: CommonElevatedButton(title: CS.vSave)),
                    ],
                  ),
                  SizedBox(height: 45),
                ],
              ).screenPadding(),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // OPEN ADD NOTE BOTTOMSHEET
  // ---------------------------------------------------------
  void _openSettingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return GetBuilder<VoiceController>(
          builder: (controller) {
            return _settingUI(controller, context);
          },
        );
      },
    );
  }

  // ---------------------------------------------------------
  // ADD NOTE BOTTOMSHEET UI
  // ---------------------------------------------------------
  Widget _settingUI(VoiceController controller, BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.colorGrey900,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- HEADER ----------------
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.colorBlack,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(CS.vFilters, style: AppTextStyles.heading3),
                    GestureDetector(onTap: () => Get.back(), child: const Icon(Icons.cancel, color: Colors.white, size: 28)),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Text(CS.vShortBy, style: AppTextStyles.heading4).screenPadding(),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  commonRoundedTextButton(text: CS.vTrending),
                  commonRoundedTextButton(text: CS.vLatest),
                  commonRoundedTextButton(text: CS.vMostPopular),
                ],
              ).screenPadding(),
              SizedBox(height: 20),
              Text(CS.vLanguage, style: AppTextStyles.heading4).screenPadding(),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadiusGeometry.circular(10), border: Border.all(color: AppColors.colorWhite)),
                child: ListTile(
                  leading: Icon(Icons.flag, color: AppColors.colorWhite),
                  title: Text("india", style: AppTextStyles.buttonTextWhite),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
           
                    children: [Text("32", style: AppTextStyles.bodyMediumGrey), Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey)],
                  ),
                ),
              ).screenPadding(),
              SizedBox(height: 20),
              Text(CS.vBestFor, style: AppTextStyles.heading4).screenPadding(),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  commonRoundedTextButton(text: CS.vNarrativeStory),
                  commonRoundedTextButton(text: CS.vConversational),
                  commonRoundedTextButton(text: CS.vCharactersAnimation),
                  commonRoundedTextButton(text: CS.vInformativeEducational),
                  commonRoundedTextButton(text: CS.vEntertainmentTV),
                ],
              ).screenPadding(),

              SizedBox(height: 20),
              Text(CS.vAge, style: AppTextStyles.heading4).screenPadding(),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [commonRoundedTextButton(text: CS.vYoung), commonRoundedTextButton(text: CS.vMiddleAged), commonRoundedTextButton(text: CS.vOld)],
              ).screenPadding(),
              SizedBox(height: 20),
              Text(CS.vGender, style: AppTextStyles.heading4).screenPadding(),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [commonRoundedTextButton(text: CS.vMale), commonRoundedTextButton(text: CS.vFemale), commonRoundedTextButton(text: CS.vNeutral)],
              ).screenPadding(),
              SizedBox(height: 50),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    flex: 1,
                    child: CommonElevatedButton(title: CS.vReset, backgroundColor: AppColors.colorBgWhite10, textStyle: AppTextStyles.buttonTextWhite),
                  ),
                  Expanded(flex: 2, child: CommonElevatedButton(title: CS.vSaveSettings)),
                ],
              ).screenPadding(),

              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  Widget commonRoundedTextButton({
    required String text,
    VoidCallback? onTap,
    double horizontal = 15,
    double vertical = 6,
    double radius = 20,
    Color bgColor = const Color(0x1AFFFFFF), // AppColors.colorBgWhite10
    TextStyle? textStyle,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(radius)),
        child: Text(text, style: textStyle ?? AppTextStyles.bodyMediumWhite16),
      ),
    );
  }
}
