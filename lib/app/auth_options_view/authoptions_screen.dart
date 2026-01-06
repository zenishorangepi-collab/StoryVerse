import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/auth_options_view/authoptions_controller.dart';
import 'package:utsav_interview/app/auth_options_view/service/auth_service.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:utsav_interview/core/pref.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class AuthOptionsScreen extends StatelessWidget {
  const AuthOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.colorWhite,
      body: GetBuilder<AuthOptionsController>(
        init: AuthOptionsController(),
        builder: (controller) {
          return Column(
            spacing: 20,
            children: [
              SizedBox(height: 50),
              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  Image.asset(CS.imgSplashLogo, height: 40, width: 40, color: AppColors.colorWhite),
                  Text(CS.vAppName, style: AppTextStyles.heading28WhiteBold),
                ],
              ),
              Text(CS.vAuthText, style: AppTextStyles.body14GreyBold),
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      overlayColor: AppColors.colorTransparent,
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: AppColors.colorGrey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: controller.isGoogleLogin && controller.isLoading ? null : Image.asset(CS.icGoogle, height: 20),
                    label: controller.isGoogleLogin && controller.isLoading ? SizedBox() : Text(CS.vContinueWithGoogle, style: AppTextStyles.body16WhiteMedium),
                    onPressed: () {
                      showTermsDialog(
                        onAgree: () async {
                          showGoogleSignInPermissionDialog(
                            onContinue: () async {
                              await GoogleSignInService.signInWithGoogle(context);
                            },
                          );
                        },
                      );
                    },
                    // onPressed: () => controller.signInWithGoogle(),
                  ),
                  controller.isGoogleLogin && controller.isLoading
                      ? Center(child: const SizedBox(height: 25, width: 25, child: CupertinoActivityIndicator(color: AppColors.colorWhite)))
                      : SizedBox(),
                ],
              ),
              // if (Platform.isIOS)
              Stack(        alignment: Alignment.center,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      overlayColor: AppColors.colorTransparent,
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: AppColors.colorGrey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: controller.isAppleLoading ? null : Image.asset(CS.icAppleLogo, height: 22, color: AppColors.colorWhite),

                    label: controller.isAppleLoading  ? SizedBox() : Text(CS.vContinueWithApple, style: AppTextStyles.body16WhiteMedium),

                    onPressed: () async {

                     await controller.signInWithApple();
                    },

                  ),
                  controller.isAppleLoading
                      ? Center(child: const SizedBox(height: 25, width: 25, child: CupertinoActivityIndicator(color: AppColors.colorWhite)))
                      : SizedBox(),
                ],
              ),

              Stack(
                alignment: Alignment.center,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      overlayColor: AppColors.colorTransparent,
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: AppColors.colorGrey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: !controller.isGoogleLogin && controller.isLoading ? null : Image.asset(CS.icProfile, height: 22, color: AppColors.colorWhite),

                    label: !controller.isGoogleLogin && controller.isLoading ? SizedBox() : Text(CS.vContinueGuest, style: AppTextStyles.body16WhiteMedium),
                    onPressed: () async {
                      await controller.signInAsGuest(context);
                    },
                    // onPressed: () => controller.signInWithGoogle(),
                  ),
                  !controller.isGoogleLogin && controller.isLoading
                      ? Center(child: const SizedBox(height: 25, width: 25, child: CupertinoActivityIndicator(color: AppColors.colorWhite)))
                      : SizedBox(),
                ],
              ),
              // ElevatedButton(
              //   style: OutlinedButton.styleFrom(
              //     minimumSize: const Size(double.infinity, 52),
              //     elevation: 0,
              //     overlayColor: AppColors.colorTransparent,
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //
              //     backgroundColor: AppColors.colorBgChipContainer,
              //   ),
              //
              //   onPressed: () {
              //     Get.toNamed(AppRoutes.loginScreen);
              //   },
              //   child: Text(CS.vLogin, style: AppTextStyles.buttonTextWhite),
              //
              //   // onPressed: () => controller.signInWithGoogle(),
              // ),
            ],
          ).screenPadding();
        },
      ),
    );
  }
}

void showTermsDialog({required VoidCallback onAgree}) {
  Get.dialog(
    AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(CS.vTermsTitle, textAlign: TextAlign.center, style: AppTextStyles.heading20BlackBold),
      content: Text(CS.vTermsDesc, textAlign: TextAlign.center, style: AppTextStyles.body14BlackRegular),
      actionsPadding: EdgeInsets.zero,
      actions: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12), right: BorderSide(color: Colors.black12))),
                  alignment: Alignment.center,
                  child: Text(CS.vCancel, style: AppTextStyles.button16BlueBold),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.back();
                  onAgree();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
                  alignment: Alignment.center,
                  child: Text(CS.vAgree, style: AppTextStyles.button16BlueBold),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.3), // overlay color
  );
}

void showGoogleSignInPermissionDialog({required VoidCallback onContinue}) {
  Get.dialog(
    CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.light, scaffoldBackgroundColor: AppColors.colorWhite, primaryColor: AppColors.colorBlack),
      child: CupertinoAlertDialog(
        title: Text(CS.vGoogleSignInTitle, style: AppTextStyles.button16BlackBold),
        content: Padding(padding: const EdgeInsets.only(top: 8), child: Text(CS.vGoogleSignInDesc, style: AppTextStyles.body14BlackRegular)),
        actions: [
          CupertinoDialogAction(onPressed: () => Get.back(), child: Text(CS.vCancel, style: AppTextStyles.button16BlackBold)),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Get.back();
              onContinue();
            },
            child: Text(CS.vContinue, style: AppTextStyles.button16BlackBold),
          ),
        ],
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.3), // overlay color
  );
}
