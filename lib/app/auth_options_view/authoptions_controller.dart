import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:utsav_interview/app/tabbar_screen/user_data_model.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/pref.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class AuthOptionsController extends GetxController {
  bool isLoading = false;
  bool isAppleLoading = false;
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
    final user = UserModel(uid: uid, email: email, name: name, photoUrl: photoUrl ?? '');

    await AppPrefs.setBool(CS.keyIsLoginIn, true);
    await AppPrefs.setString(CS.keyUserData, jsonEncode(user.toJson())); // ✅ Call toJson()
  }

  Future<void> signInWithApple() async {
    try {
      // Show loading
      isAppleLoading = true;
update();
      // Check if Apple Sign-In is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        Get.snackbar(
          'Not Available',
          'Apple Sign-In is not available on this device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Get Apple ID credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Validate credential
      if (credential.userIdentifier == null || credential.userIdentifier!.isEmpty) {
        throw Exception('Invalid user identifier from Apple');
      }

      // Extract user information
      final String uid = credential.userIdentifier!;
      final String email = credential.email ?? '';
      final String firstName = credential.givenName ?? '';
      final String lastName = credential.familyName ?? '';
      final String fullName = _buildFullName(firstName, lastName);

      // Debug print
      debugPrint('Apple Sign-In Success:');
      debugPrint('UID: $uid');
      debugPrint('Email: $email');
      debugPrint('Name: $fullName');
      debugPrint('Identity Token: ${credential.identityToken}');
      debugPrint('Authorization Code: ${credential.authorizationCode}');

      // Check if this is first-time sign-in or returning user
      final isNewUser = await _checkIfNewUser(uid);

      // Save user data
      await saveUserAsMap(
        uid: uid,
        email: email,
        name: fullName.isEmpty ? email.split('@').first : fullName,
      );

      // Mark user as logged in
      await AppPrefs.setBool(CS.keyIsLoginIn, true);
      await AppPrefs.setString(CS.keyUserId, uid);

      // Show success message
      Get.snackbar(
        'Success',
        'Signed in successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate based on user status
      if (isNewUser) {
        // New user - go to onboarding/DOB screen
        Get.offAllNamed(AppRoutes.dobScreen);
      } else {
        // Returning user - go to home
        Get.offAllNamed(AppRoutes.homeScreen);
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // Handle specific Apple Sign-In errors
      _handleAppleSignInError(e);
    } catch (e) {
      // Handle general errors
      debugPrint('Apple Sign-In Error: $e');
      Get.snackbar(
        'Error',
        'Failed to sign in with Apple: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      // Hide loading
      isAppleLoading = false;
      update();
    }
  }

  // Build full name from first and last name
  String _buildFullName(String firstName, String lastName) {
    final parts = <String>[];
    if (firstName.isNotEmpty) parts.add(firstName);
    if (lastName.isNotEmpty) parts.add(lastName);
    return parts.join(' ');
  }

  // Check if user is new or returning
  Future<bool> _checkIfNewUser(String uid) async {
    // Check if user exists in your database/preferences
    final existingUserId = await AppPrefs.getString(CS.keyUserId);
    return existingUserId == null || existingUserId.isEmpty || existingUserId != uid;
  }
  void _handleAppleSignInError(SignInWithAppleAuthorizationException error) {
    String message;

    switch (error.code) {
      case AuthorizationErrorCode.canceled:
        message = 'Sign in was cancelled';
        break;
      case AuthorizationErrorCode.failed:
        message = 'Sign in failed. Please try again';
        break;
      case AuthorizationErrorCode.invalidResponse:
        message = 'Invalid response from Apple';
        break;
      case AuthorizationErrorCode.notHandled:
        message = 'Sign in not handled';
        break;
      case AuthorizationErrorCode.unknown:
        message = 'An unknown error occurred';
        break;
      default:
        message = 'Sign in failed: ${error.message}';
    }

    debugPrint('Apple Sign-In Error: ${error.code} - $message');

    // Don't show error for cancelled sign-in
    if (error.code != AuthorizationErrorCode.canceled) {
      Get.snackbar(
        'Sign In Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await AppPrefs.setBool(CS.keyIsLoginIn, false);
      await AppPrefs.remove(CS.keyUserId);
      await AppPrefs.clear();
      Get.offAllNamed(AppRoutes.loginScreen);

      Get.snackbar(
        'Signed Out',
        'You have been signed out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
}
