import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';

import 'package:utsav_interview/app/auth_options_view/authoptions_controller.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
import 'package:utsav_interview/app/tabbar_screen/user_data_model.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/pref.dart';
import 'package:utsav_interview/routes/app_routes.dart';

import '../../tabbar_screen/tabbar_controller.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialize = false;

  static Future<void> initSignIn() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(
        serverClientId:
        '307426584956-1d2nnjnjndnfo76b07l536t8e5h6rfcv.apps.googleusercontent.com',
      );
      isInitialize = true;
    }
  }

  /* ----------------------------------------------------
   * GOOGLE SIGN-IN
   * -------------------------------------------------- */

  static Future<void> signInWithGoogle(BuildContext context) async {
    final controller = Get.find<AuthOptionsController>();
    controller.setLoading(true);

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

      final userCredential =
      await _auth.signInWithCredential(credential);

      await _handlePostLogin(userCredential, controller);
    } catch (e) {
      _showError(context, 'Google login failed');
      debugPrint('❌ Google Sign-In Error: $e');
    } finally {
      controller.setLoading(false);
    }
  }

  /* ----------------------------------------------------
   * APPLE SIGN-IN
   * -------------------------------------------------- */

  static Future<void> signInWithApple() async {
    final controller = Get.find<AuthOptionsController>();
    controller.isAppleLoading = true;
    controller.update();

    try {
      if (!await SignInWithApple.isAvailable()) {
        throw Exception('Apple Sign-In not available');
      }

      final appleCredential =
      await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthProvider = OAuthProvider('apple.com');
      final credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
      await _auth.signInWithCredential(credential);

      await _handlePostLogin(
        userCredential,
        controller,
        appleCredential: appleCredential,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      _handleAppleError(e);
    } catch (e) {
      debugPrint('❌ Apple Sign-In Error: $e');
      Get.snackbar(
        'Error',
        'Apple login failed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      controller.isAppleLoading = false;
      controller.update();
    }
  }

  /* ----------------------------------------------------
   * COMMON POST LOGIN HANDLER
   * -------------------------------------------------- */

  static Future<void> _handlePostLogin(
      UserCredential credential,
      AuthOptionsController controller, {
        AuthorizationCredentialAppleID? appleCredential,
      }) async {
    final user = credential.user;
    if (user == null) throw Exception('User is null');

    final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;

    final name = appleCredential != null
        ? _buildFullName(
      appleCredential.givenName,
      appleCredential.familyName,
    )
        : user.displayName ?? '';

    await controller.saveUserAsMap(
      uid: user.uid,
      email: user.email ?? '',
      name: name.isNotEmpty ? name : user.email!.split('@').first,
      photoUrl: user.photoURL,
    );

    await AppPrefs.setBool(CS.keyIsLoginIn, true);
    await AppPrefs.setString(CS.keyUserId, user.uid);

    Get.offAllNamed(
      isNewUser ? AppRoutes.dobScreen : AppRoutes.tabBarScreen,
    );
  }

  /* ----------------------------------------------------
   * SIGN OUT
   * -------------------------------------------------- */

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      isBookListening.value = false;
      isPlayAudio.value = false;
      isAudioInitCount.value = 0;
      bookInfo.value = NovelsDataModel();
      userData = null;

      await AppPrefs.clear();
      Get.offAllNamed(AppRoutes.authOptionsScreen);
    } catch (_) {}

    // await AppPrefs.setBool(CS.keyIsLoginIn, false);
    // await AppPrefs.remove(CS.keyUserId);
    // await AppPrefs.clear();
    //
    // Get.offAllNamed(AppRoutes.authOptionsScreen);
  }

  /* ----------------------------------------------------
   * HELPERS
   * -------------------------------------------------- */

  static String _buildFullName(String? first, String? last) {
    return [first, last].where((e) => e != null && e.isNotEmpty).join(' ');
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.colorChipBackground,
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(message, style: AppTextStyles.body14WhiteMedium),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _handleAppleError(
      SignInWithAppleAuthorizationException error) {
    if (error.code == AuthorizationErrorCode.canceled) return;

    Get.snackbar(
      'Apple Sign-In Failed',
      error.message ?? 'Unknown error',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
