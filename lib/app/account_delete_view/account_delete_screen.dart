import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/account_delete_view/account_delete_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeleteAccountController>(
      init: DeleteAccountController(),
      builder: (controller) {
        return Scaffold(
          // backgroundColor: const Color(0xFF121212), // Dark background
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 60,
            leading: commonCircleButton(
              iconSize: 18,
              leftPadding: 2,
              onTap: () {
                Get.back();
              },
            ).paddingOnly(left: 25),
          ),
          body: SingleChildScrollView(
            child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(CS.vDeleteAccountTitle, style: AppTextStyles.heading24WhiteMedium),
                    const SizedBox(height: 24),
                    Text(CS.vDeleteAccountHintText, style: AppTextStyles.body16GreyMedium, strutStyle: StrutStyle(height: 1.8)),
                    const SizedBox(height: 25),
                    // Email Input Field
                    TextField(
                      controller: controller.emailInputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: controller.targetEmail,
                        hintStyle: AppTextStyles.body14GreySemiBold,
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[800]!, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(CS.vDeleteAccountWarning, style: AppTextStyles.body16GreyMedium, strutStyle: StrutStyle(height: 1.8)),
                    const SizedBox(height: 50),
                    // Reactive Delete Button
                    CommonElevatedButton(
                      title: CS.vDeleteAccount,
                      onTap: controller.isButtonEnabled.value ? () => controller.deleteAccount() : null,
                      backgroundColor: controller.isButtonEnabled.value ? AppColors.colorRed : AppColors.colorDarkRed,
                      textStyle: controller.isButtonEnabled.value ? AppTextStyles.button16WhiteBold : AppTextStyles.button16BlackBold,
                      radius: 10,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),

                    const SizedBox(height: 40),
                  ],
                ).screenPadding(),
          ),
        );
      },
    );
  }
}
