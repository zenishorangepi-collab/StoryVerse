import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/auth_options_view/authoptions_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class AuthOptionsScreen extends StatelessWidget {
  const AuthOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                children: [Image.asset(CS.imgSplashLogo, color: AppColors.colorWhite, height: 40, width: 40), Text(CS.vAppName, style: AppTextStyles.heading1)],
              ),
              Text(CS.vAuthText, style: AppTextStyles.bodyLargeGray14Bold),
              SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  overlayColor: AppColors.colorTransparent,
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: AppColors.colorBgWhite10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Image.asset(CS.icGoogle, height: 20),
                label: Text(CS.vContinueWithGoogle, style: AppTextStyles.bodyLarge),
                onPressed: () async {
                  await AuthService().signInWithGoogleFirebase();
                },
                // onPressed: () => controller.signInWithGoogle(),
              ),
              if (Platform.isIOS)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    overlayColor: AppColors.colorTransparent,
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: AppColors.colorBgWhite10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Image.asset(CS.icAppleLogo, height: 20),
                  label: Text(CS.vContinueWithApple, style: AppTextStyles.bodyLarge),
                  onPressed: () {},
                  // onPressed: () => controller.signInWithGoogle(),
                ),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  overlayColor: AppColors.colorTransparent,
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: AppColors.colorBgWhite10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Image.asset(CS.icProfile, height: 20),
                label: Text(CS.vContinueGuest, style: AppTextStyles.bodyLarge),
                onPressed: () async {
                  await controller.signInAsGuest();
                },
                // onPressed: () => controller.signInWithGoogle(),
              ),
              ElevatedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 0,
                  overlayColor: AppColors.colorTransparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

                  backgroundColor: AppColors.colorBgChipContainer,
                ),

                onPressed: () {
                  Get.toNamed(AppRoutes.loginScreen);
                },
                child: Text(CS.vLogin, style: AppTextStyles.buttonTextWhite),

                // onPressed: () => controller.signInWithGoogle(),
              ),
            ],
          ).screenPadding();
        },
      ),
    );
  }
}
