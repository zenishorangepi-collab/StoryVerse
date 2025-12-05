import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/sound_spaces_view/sound_spaces_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
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

                      GestureDetector(onTap: () => Get.back(), child: const Icon(Icons.cancel, color: Colors.white, size: 28)),
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
                          color: WidgetStatePropertyAll(AppColors.colorBgWhite02),

                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(CS.vSoundscapeVolume, style: AppTextStyles.bodyMediumGrey16),
                  Slider(
                    min: 0,
                    padding: EdgeInsets.all(5),
                    max: 100,
                    value: controller.sliderPosition,
                    activeColor: AppColors.colorWhite,
                    inactiveColor: AppColors.colorBgWhite02,
                    // overlayColor: WidgetStatePropertyAll(AppColors.colorWhite),
                    onChanged: (value) {
                      controller.sliderPosition = value;
                      controller.update();
                    },
                  ),
                  SizedBox(height: 20),
                  Text(CS.vAllSoundscape, style: AppTextStyles.bodyMediumGrey16),
                  ListView.builder(
                    itemBuilder: (context, index) {
                      return ListTile();
                    },
                  ),
                ],
              ).screenPadding(),
        );
      },
    );
  }
}
