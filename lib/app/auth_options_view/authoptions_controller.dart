import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/tabbar_screen/user_data_model.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/pref.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class AuthOptionsController extends GetxController {
  bool isLoading = false;
  bool isGoogleLogin = false;

  void setLoading(bool value) {
    isLoading = value;

    update();
  }

  Future<void> signInAsGuest(BuildContext context) async {
    final controller = Get.find<AuthOptionsController>();

    try {
      controller.setLoading(true); // 🔥 START LOADING

      final userCredential = await FirebaseAuth.instance.signInAnonymously();

      final user = userCredential.user;

      if (user != null) {
        debugPrint('Guest UID: ${user.uid}');

        AppPrefs.setBool(CS.keyIsLoginIn, true);
        Get.offAllNamed(AppRoutes.dobScreen);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.colorChipBackground,
          content: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.colorRed),
              const SizedBox(width: 8),
              Text("Guest login failed", style: AppTextStyles.body14RedBold),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      debugPrint('Guest login failed: $e');
    } finally {
      controller.setLoading(false); // 🔥 STOP LOADING ALWAYS
    }
  }

  Future<void> saveUserAsMap({required String uid, required String email, required String name, String? photoUrl}) async {
    // final Map<String, dynamic> userMap = {'uid': uid, 'email': email, 'name': name, 'photoUrl': photoUrl ?? ''};
    final user = UserModel(uid: uid, email: email ?? '', name: name ?? '', photoUrl: photoUrl ?? '');
    await AppPrefs.setBool(CS.keyIsLoginIn, true);
    await AppPrefs.setString(CS.keyUserData, jsonEncode(user));
  }
}
