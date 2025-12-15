import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/pref.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class AuthOptionsController extends GetxController {
  Future<void> signInAsGuest(context) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();

      final user = userCredential.user;

      if (user != null) {
        print('Guest UID: ${user.uid}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.colorBgChipContainer,
            content: Row(
              spacing: 10,
              children: [Icon(Icons.error_outline, color: AppColors.colorRed), Text("Guest login failed", style: AppTextStyles.bodyMediumRedBold)],
            ),
            duration: const Duration(seconds: 2),
            // width: 280.0,
            // Width of the SnackBar.,
            padding: const EdgeInsets.all(10),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          ),
        );
        AppPrefs.setBool(CS.keyIsLoginIn, true);
        // Get.offAllNamed(AppRoutes.tabBarScreen);
      }
    } catch (e) {
      print('Guest login failed: $e');
    }
  }

  Future<void> saveUserAsMap({required String uid, required String email, required String name, String? photoUrl}) async {
    final Map<String, dynamic> userMap = {'uid': uid, 'email': email, 'name': name, 'photoUrl': photoUrl ?? ''};

    await AppPrefs.setBool(CS.keyIsLoginIn, true);
    await AppPrefs.setString(CS.keyUserData, jsonEncode(userMap));
  }
}
