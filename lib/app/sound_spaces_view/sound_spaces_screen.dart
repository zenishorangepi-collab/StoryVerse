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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 45),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(CS.vSoundScapes, style: AppTextStyles.heading24WhiteMedium),

                  commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                ],
              ).screenPadding(),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(controller.listChipName.length, (index) {
                    return commonChip(label: controller.listChipName[index]).paddingOnly(left: index == 0 ? 18 : 0);
                  }),
                ),
              ),
              SizedBox(height: 20),
              Text(CS.vSoundscapeVolume, style: AppTextStyles.body16GreyBold).screenPadding(),
              SizedBox(height: 20),

              Slider(
                min: 0,
                padding: EdgeInsets.all(5),
                max: 100,
                value: controller.sliderPosition,
                activeColor: AppColors.colorWhite,
                inactiveColor: AppColors.colorBgWhite10,

                // overlayColor: WidgetStatePropertyAll(AppColors.colorWhite),
                onChanged: (value) {
                  controller.sliderPosition = value;
                  controller.update();
                },
              ).screenPadding(),
              SizedBox(height: 25),
              Text(CS.vAllSoundscape, style: AppTextStyles.body16GreyBold).screenPadding(),
              SizedBox(height: 10),
              Expanded(
                child:
                    ListView.builder(
                      padding: EdgeInsets.zero,
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
                            title: Text("Turn off soundscapces", style: AppTextStyles.body14WhiteBold),
                            trailing: controller.selectedTile == index ? Icon(Icons.check_circle_rounded, color: AppColors.colorWhite) : null,
                          ).paddingOnly(bottom: 6),
                        );
                      },
                    ).screenPadding(),
              ),
              SizedBox(height: 10),
              Row(
                spacing: 15,
                children: [
                  Expanded(
                    child: CommonElevatedButton(title: CS.vReset, backgroundColor: AppColors.colorChipBackground, textStyle: AppTextStyles.button16WhiteBold),
                  ),
                  Expanded(child: CommonElevatedButton(title: CS.vSave)),
                ],
              ).screenPadding(),
              SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }
}
