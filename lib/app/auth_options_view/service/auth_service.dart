import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:utsav_interview/app/auth_options_view/authoptions_controller.dart';
import 'package:utsav_interview/app/auth_options_view/authoptions_screen.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/pref.dart';
import 'package:utsav_interview/routes/app_routes.dart';
import 'package:get/get.dart';

// Google Sign-In Service Class
class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialize = false;

  static Future<void> initSignIn() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(serverClientId: '307426584956-1d2nnjnjndnfo76b07l536t8e5h6rfcv.apps.googleusercontent.com');
    }
    isInitialize = true;
  }

  /// Sign in with Google
  static Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    final controller = Get.find<AuthOptionsController>();
    controller.isGoogleLogin = true;
    try {
      initSignIn();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      controller.setLoading(true); // 🔥 START LOADING
      final googleAuth = await googleUser.authentication;

      final authorization = await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);

      final accessToken = authorization?.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw FirebaseAuthException(code: "GOOGLE_AUTH_FAILED", message: "Google sign-in failed");
      }

      final credential = GoogleAuthProvider.credential(accessToken: accessToken, idToken: idToken);

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
      debugPrint('✅ Firebase Authentication successful: ${user.uid}');
        await controller.saveUserAsMap(uid: user.uid, email: user.email ?? '', name: user.displayName ?? '', photoUrl: user.photoURL);

        AppPrefs.setBool(CS.keyIsLoginIn, true);
        final isNewUser = await _checkIfNewUser(user.uid);
        if (isNewUser) {
          Get.offAllNamed(AppRoutes.dobScreen);
        } else {
          Get.offAllNamed(AppRoutes.tabBarScreen);
        }
      }

      return userCredential;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.colorChipBackground,
          content: Row(children:  [Icon(Icons.error_outline, color: Colors.red), SizedBox(width: 8), Text("Login failed",style: AppTextStyles.body14WhiteMedium,)]),
          behavior: SnackBarBehavior.floating,
        ),
      );
      rethrow;
    } finally {
      controller.setLoading(false); // 🔥 STOP LOADING (ALWAYS)
    }
  }

  /// Apple
  static Future<void> signInWithApple() async {
      final controller = Get.find<AuthOptionsController>();
    try {
      controller.isAppleLoading = true;
      controller.update();

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

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        throw Exception('Unable to fetch identity token from Apple');
      }

      final oAuthProvider = OAuthProvider('apple.com');
      final firebaseCredential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(firebaseCredential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Failed to authenticate with Firebase');
      }

      debugPrint('✅ Firebase Authentication successful: ${firebaseUser.uid}');

      final String uid = firebaseUser.uid;
      final String email = appleCredential.email ?? firebaseUser.email ?? '';
      final String firstName = appleCredential.givenName ?? '';
      final String lastName = appleCredential.familyName ?? '';
      final String fullName = buildFullName(firstName, lastName);

      final isNewUser = await _checkIfNewUser(uid);


      await controller.saveUserAsMap(
        uid: uid,
        email: email,
        name: fullName.isEmpty
            ? email.split('@').first.split(RegExp(r'[^a-zA-Z0-9]')).first
            : fullName,
      );

      // Save to local preferences
      await AppPrefs.setBool(CS.keyIsLoginIn, true);
      await AppPrefs.setString(CS.keyUserId, uid);

      debugPrint('✅ User data saved successfully');

      if (isNewUser) {
        Get.offAllNamed(AppRoutes.dobScreen);
      } else {
        Get.offAllNamed(AppRoutes.tabBarScreen);
      }

    } on SignInWithAppleAuthorizationException catch (e) {
      _handleAppleSignInError(e);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      Get.snackbar(
        'Authentication Error',
        'Failed to authenticate: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      // Handle general errors
      debugPrint('❌ Apple Sign-In Error: $e');
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
      controller.isAppleLoading = false;
      controller.update();
    }
  }


  static String buildFullName(String firstName, String lastName) {
    final parts = <String>[];
    if (firstName.isNotEmpty) parts.add(firstName);
    if (lastName.isNotEmpty) parts.add(lastName);
    return parts.join(' ');
  }

  static Future<bool> _checkIfNewUser(String uid) async {
    final existingUserId = await AppPrefs.getString(CS.keyUserId);
    return existingUserId == null || existingUserId.isEmpty || existingUserId != uid;
  }

  static _handleAppleSignInError(SignInWithAppleAuthorizationException error) {
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
  static Future<void> signOut() async {
    try {
      await _auth.signOut();

      try {
        await _googleSignIn.signOut();

      } catch (e) {
        // Silent fail for Google sign out
      }

      await AppPrefs.setBool(CS.keyIsLoginIn, false);
      // await AppPrefs.remove(CS.keyUserId);

      Get.offAllNamed(AppRoutes.authOptionsScreen);


    } catch (e) {
      await AppPrefs.setBool(CS.keyIsLoginIn, false);
      // await AppPrefs.remove(CS.keyUserId);
      Get.offAllNamed(AppRoutes.authOptionsScreen);

    }
  }
}
