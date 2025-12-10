import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/sound_spaces_view/sound_spaces_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';

import '../../core/common_function.dart';

class SoundSpacesScreen extends StatelessWidget {
  const SoundSpacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SoundSpacesController>(
      init: SoundSpacesController(),
      builder: (controller) {
        return Scaffold(
          body:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 45),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(CS.vSoundScapes, style: AppTextStyles.heading2),

                      commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                    ],
                  ),
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 10,
                      children: List.generate(controller.listChipName.length, (index) {
                        return Chip(
                          label: Text(controller.listChipName[index], style: AppTextStyles.bodyMedium),
                          color: WidgetStatePropertyAll(AppColors.colorBgGray02),

                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(CS.vSoundscapeVolume, style: AppTextStyles.bodyMediumGrey16),
                  SizedBox(height: 20),

                  Slider(
                    min: 0,
                    padding: EdgeInsets.all(5),
                    max: 100,
                    value: controller.sliderPosition,
                    activeColor: AppColors.colorWhite,
                    inactiveColor: AppColors.colorBgGray02,
                    // overlayColor: WidgetStatePropertyAll(AppColors.colorWhite),
                    onChanged: (value) {
                      controller.sliderPosition = value;
                      controller.update();
                    },
                  ),
                  SizedBox(height: 30),
                  Text(CS.vAllSoundscape, style: AppTextStyles.bodyMediumGrey16),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            controller.selectedTile = index;
                            controller.update();
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.all(5),
                            leading: Container(
                              height: 50,
                              width: 50,
                              // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              // margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                gradient: controller.myGradient,
                                borderRadius: BorderRadius.circular(25), // rounded
                              ),
                            ),
                            title: Text("Turn off soundscapces", style: AppTextStyles.bodyLarge),
                            trailing: controller.selectedTile == index ? Icon(Icons.check_circle_rounded, color: AppColors.colorWhite) : null,
                          ).paddingOnly(bottom: 6),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    spacing: 15,
                    children: [
                      Expanded(
                        child: CommonElevatedButton(title: CS.vReset, backgroundColor: AppColors.colorBgGray02, textStyle: AppTextStyles.buttonTextWhite),
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
}
