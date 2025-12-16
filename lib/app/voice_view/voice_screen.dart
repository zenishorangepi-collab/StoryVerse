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
import 'language_bottomsheet.dart';

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
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: Text(CS.vSelectVoice, style: AppTextStyles.heading24WhiteMedium)),

                      Row(
                        spacing: 10,
                        children: [
                          commonCircleButton(onTap: () {}, iconPath: CS.icSearch, iconSize: 22, padding: 11),
                          commonCircleButton(
                            iconSize: 20,
                            padding: 12,
                            onTap: () {
                              _openSettingSheet(context);
                            },
                            iconPath: CS.icSettings,
                          ),

                          commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 16, padding: 14),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(child: buildChip(icon: Icons.access_time_filled, label: CS.vRecents)),
                      Expanded(child: buildChip(icon: Icons.favorite, label: CS.vFavorites)),
                      Expanded(child: buildChip(icon: Icons.explore, label: CS.vExplore)),
                    ],
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
                            title: Text("Turn off soundscapces", style: AppTextStyles.body14WhiteBold, maxLines: 2, overflow: TextOverflow.ellipsis),
                            subtitle: Text("subtitle", style: AppTextStyles.body14GreyRegular),
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
                        child: CommonElevatedButton(
                          title: CS.vReset,
                          backgroundColor: AppColors.colorChipBackground,
                          textStyle: AppTextStyles.button16WhiteBold,
                        ),
                      ),
                      Expanded(child: CommonElevatedButton(title: CS.vSave)),
                    ],
                  ),
                  SizedBox(height: 60),
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
      backgroundColor: AppColors.colorBgGray02,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
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
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: AppColors.colorBgGray02,
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
                  color: AppColors.colorDialogHeader,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(CS.vFilters, style: AppTextStyles.heading20WhiteSemiBold),
                    commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(CS.vShortBy, style: AppTextStyles.body16WhiteBold).screenPadding(),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          commonRoundedTextButton(
                            text: CS.vTrending,
                            onTap: () {
                              if (controller.selectedShortBy == CS.vTrending) {
                                controller.selectedShortBy = "";
                              } else {
                                controller.selectedShortBy = CS.vTrending;
                              }
                              controller.update();
                            },
                            selectedChip: controller.selectedShortBy,
                          ),
                          commonRoundedTextButton(
                            text: CS.vLatest,
                            onTap: () {
                              if (controller.selectedShortBy == CS.vLatest) {
                                controller.selectedShortBy = "";
                              } else {
                                controller.selectedShortBy = CS.vLatest;
                              }
                              controller.update();
                            },
                            selectedChip: controller.selectedShortBy,
                          ),
                          commonRoundedTextButton(
                            text: CS.vMostPopular,
                            onTap: () {
                              if (controller.selectedShortBy == CS.vMostPopular) {
                                controller.selectedShortBy = "";
                              } else {
                                controller.selectedShortBy = CS.vMostPopular;
                              }
                              controller.update();
                            },
                            selectedChip: controller.selectedShortBy,
                          ),
                        ],
                      ).screenPadding(),
                      SizedBox(height: 20),
                      Text(CS.vLanguage, style: AppTextStyles.body16WhiteBold).screenPadding(),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final result = await showLanguageBottomSheet(context, selectedLanguage: controller.selectedLang);

                          if (result != null) {
                            controller.selectedLang = result["name"]!;
                            controller.selectedFlag = result["flag"]!;

                            controller.update();
                          }
                        },
                        child:
                            Container(
                              decoration: BoxDecoration(borderRadius: BorderRadiusGeometry.circular(10), border: Border.all(color: AppColors.colorWhite)),
                              child: ListTile(
                                leading:
                                    controller.selectedFlag == null
                                        ? Icon(Icons.language, color: AppColors.colorWhite)
                                        : Text(controller.selectedFlag ?? "", style: AppTextStyles.heading20WhiteSemiBold),
                                title: Text(controller.selectedLang ?? CS.vFilterLanguage, style: AppTextStyles.body16WhiteBold),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,

                                  children: [Text("32", style: AppTextStyles.body14GreyRegular), Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey)],
                                ),
                              ),
                            ).screenPadding(),
                      ),
                      SizedBox(height: 20),
                      Text(CS.vBestFor, style: AppTextStyles.body16WhiteBold).screenPadding(),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children:
                            controller.listBestForItems
                                .map(
                                  (text) => commonRoundedTextButton(
                                    text: text,
                                    selectChipOnce: false,
                                    isSelectedChip: controller.listSelectedBestFor.contains(text),
                                    onTap: () {
                                      if (controller.listSelectedBestFor.contains(text)) {
                                        controller.listSelectedBestFor.remove(text); // unselect
                                      } else {
                                        controller.listSelectedBestFor.add(text); // select
                                      }

                                      controller.update();
                                    },
                                  ),
                                )
                                .toList(),
                      ).screenPadding(),

                      SizedBox(height: 20),
                      Text(CS.vAge, style: AppTextStyles.body16WhiteBold).screenPadding(),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          commonRoundedTextButton(
                            text: CS.vYoung,
                            selectedChip: controller.selectedAge,
                            onTap: () {
                              if (controller.selectedAge == CS.vYoung) {
                                controller.selectedAge = "";
                              } else {
                                controller.selectedAge = CS.vYoung;
                              }
                              controller.update();
                            },
                          ),
                          commonRoundedTextButton(
                            text: CS.vMiddleAged,
                            selectedChip: controller.selectedAge,
                            onTap: () {
                              if (controller.selectedAge == CS.vMiddleAged) {
                                controller.selectedAge = "";
                              } else {
                                controller.selectedAge = CS.vMiddleAged;
                              }
                              controller.update();
                            },
                          ),
                          commonRoundedTextButton(
                            text: CS.vOld,
                            selectedChip: controller.selectedAge,
                            onTap: () {
                              if (controller.selectedAge == CS.vOld) {
                                controller.selectedAge = "";
                              } else {
                                controller.selectedAge = CS.vOld;
                              }
                              controller.update();
                            },
                          ),
                        ],
                      ).screenPadding(),
                      SizedBox(height: 20),
                      Text(CS.vGender, style: AppTextStyles.body16WhiteBold).screenPadding(),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          commonRoundedTextButton(
                            text: CS.vMale,
                            selectedChip: controller.selectedGender,
                            onTap: () {
                              if (controller.selectedGender == CS.vMale) {
                                controller.selectedGender = "";
                              } else {
                                controller.selectedGender = CS.vMale;
                              }
                              controller.update();
                            },
                          ),
                          commonRoundedTextButton(
                            text: CS.vFemale,
                            selectedChip: controller.selectedGender,
                            onTap: () {
                              if (controller.selectedGender == CS.vFemale) {
                                controller.selectedGender = "";
                              } else {
                                controller.selectedGender = CS.vFemale;
                              }
                              controller.update();
                            },
                          ),
                          commonRoundedTextButton(
                            text: CS.vNeutral,
                            selectedChip: controller.selectedGender,
                            onTap: () {
                              if (controller.selectedGender == CS.vNeutral) {
                                controller.selectedGender = "";
                              } else {
                                controller.selectedGender = CS.vNeutral;
                              }
                              controller.update();
                            },
                          ),
                        ],
                      ).screenPadding(),
                      SizedBox(height: 50),
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            flex: 1,
                            child: CommonElevatedButton(
                              title: CS.vReset,
                              backgroundColor: AppColors.colorChipBackground,
                              textStyle: AppTextStyles.button16WhiteBold,
                            ),
                          ),
                          Expanded(flex: 2, child: CommonElevatedButton(title: CS.vSaveSettings)),
                        ],
                      ).screenPadding(),

                      const SizedBox(height: 35),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget commonRoundedTextButton({
    required String text,
    String? selectedChip,
    VoidCallback? onTap,
    double horizontal = 15,
    double vertical = 6,
    double radius = 20,
    bool selectChipOnce = true,
    bool isSelectedChip = false,
    Color bgColor = const Color(0x1AFFFFFF), // AppColors.colorBgWhite10
    TextStyle? textStyle,
  }) {
    final bool isSelected = (selectChipOnce ? selectedChip == text : isSelectedChip);

    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        decoration: BoxDecoration(color: isSelected ? AppColors.colorWhite : bgColor, borderRadius: BorderRadius.circular(radius)),
        child: Text(text, style: textStyle ?? (isSelected ? AppTextStyles.button14BlackBold : AppTextStyles.body14WhiteBold)),
      ),
    );
  }
}
