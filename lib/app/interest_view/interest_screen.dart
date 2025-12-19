import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/interest_view/interest_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class InterestScreen extends StatelessWidget {
  const InterestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InterestController>(
      builder: (controller) {
        return Scaffold(
          // backgroundColor: AppColors.colorWhite,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Text(CS.vWhatAreYourInterest, style: AppTextStyles.heading20WhiteSemiBold),
                  const SizedBox(height: 30),

                  // -------- INTEREST LIST --------
                  Expanded(
                    child: ListView.separated(
                      itemCount: controller.interests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = controller.interests[index];
                        final isSelected = controller.selectedIndexes.contains(index);

                        return commonListTile(
                          icon: item.icon,
                          tileColor: isSelected ? AppColors.colorWhite : AppColors.colorChipBackground,
                          iconColor: isSelected ? AppColors.colorBlack : AppColors.colorWhite,
                          title: item.title,
                          style: isSelected ? AppTextStyles.button16BlackBold : AppTextStyles.button16WhiteBold,
                          // trailing: isSelected ? Icon(Icons.check_circle, color: Colors.black) : SizedBox(),
                          onTap: () {
                            controller.toggleSelection(index);
                            controller.update();
                          },
                        );
                      },
                    ),
                  ),
                  // -------- CONTINUE BUTTON --------
                  CommonElevatedButton(
                    onTap:
                        controller.isContinueEnabled
                            ? () {
                              Get.toNamed(AppRoutes.referral);
                            }
                            : null,
                    // isDark: true,
                    backgroundColor: controller.isContinueEnabled ? AppColors.colorWhite : AppColors.colorGrey,
                    title: CS.vContinue,
                    textStyle: controller.isContinueEnabled ? AppTextStyles.button16BlackBold : AppTextStyles.body16WhiteMedium,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
