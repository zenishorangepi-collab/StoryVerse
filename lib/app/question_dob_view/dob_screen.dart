import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/question_dob_view/dob_controller.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class DobScreen extends StatelessWidget {
  const DobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DobController>(
      builder: (controller) {
        return Scaffold(
          // backgroundColor: AppColors.colorWhite,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Text(CS.vWhatYourDateOfBirth, style: AppTextStyles.heading20WhiteSemiBold),
                  const SizedBox(height: 8),
                  Text(CS.vWeAskForYourDateOfBirth, textAlign: TextAlign.center, style: AppTextStyles.body14GreyBold),
                  const SizedBox(height: 50),

                  SizedBox(
                    height: 250,
                    child: Row(
                      children: [
                        _picker<int>(
                          controller: controller,
                          scrollController: controller.dayController,
                          items: controller.listDays,
                          type: PickerType.day,
                          itemBuilder: (v) => v.toString(),
                        ),
                        _picker<String>(
                          controller: controller,
                          scrollController: controller.monthController,
                          items: controller.listMonths,
                          type: PickerType.month,
                          isMonth: true,
                          itemBuilder: (v) => v,
                        ),
                        _picker<int>(
                          controller: controller,
                          scrollController: controller.yearController,
                          items: controller.years,
                          type: PickerType.year,
                          itemBuilder: (v) => v.toString(),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  CommonElevatedButton(
                    onTap: () {
                      Get.toNamed(AppRoutes.preference);
                    },

                    title: CS.vContinue,
                  ),

                  const SizedBox(height: 5),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.preference);
                    },
                    child: Text(CS.vSkip, style: AppTextStyles.button16WhiteBold),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _picker<T>({
    required DobController controller,
    required List items,
    required PickerType type,
    required FixedExtentScrollController scrollController,
    required String Function(dynamic) itemBuilder,
    bool isMonth = false,
  }) {
    return Expanded(
      child: Stack(
        children: [
          // Wheel
          ListWheelScrollView.useDelegate(
            controller: scrollController,
            itemExtent: 35,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 1.5,
            perspective: 0.005,
            onSelectedItemChanged: (index) {
              if (type == PickerType.day) {
                controller.selectedDay = items[index];
              } else if (type == PickerType.month) {
                controller.selectedMonth = index + 1;
              } else {
                controller.selectedYear = items[index];
              }
              controller.update();
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (context, index) {
                final isSelected =
                    type == PickerType.day
                        ? controller.selectedDay == items[index]
                        : type == PickerType.month
                        ? controller.selectedMonth == index + 1
                        : controller.selectedYear == items[index];

                return Center(
                  child: Text(itemBuilder(items[index]), style: isSelected ? AppTextStyles.heading20WhiteSemiBold : AppTextStyles.body20GreyMedium),
                );
              },
            ),
          ),

          // // 🔥 TOP SHADOW
          // Positioned(
          //   top: 10,
          //   left: 0,
          //   right: 0,
          //   height: 40,
          //   child: IgnorePointer(
          //     child: Container(
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.colorBgWhite10]),
          //       ),
          //     ),
          //   ),
          // ),
          //
          // // 🔥 BOTTOM SHADOW
          // Positioned(
          //   bottom: 10,
          //   left: 0,
          //   right: 0,
          //   height: 40,
          //   child: IgnorePointer(
          //     child: Container(
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.white, Colors.white.withOpacity(0.0)]),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
    ;
  }
}
