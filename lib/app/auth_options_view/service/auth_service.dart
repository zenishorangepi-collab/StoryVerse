import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  // Sign in with Google
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
        await controller.saveUserAsMap(uid: user.uid, email: user.email ?? '', name: user.displayName ?? '', photoUrl: user.photoURL);

        AppPrefs.setBool(CS.keyIsLoginIn, true);
        Get.offAllNamed(AppRoutes.dobScreen);
      }

      return userCredential;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.colorChipBackground,
          content: Row(children: const [Icon(Icons.error_outline, color: Colors.red), SizedBox(width: 8), Text("Login failed")]),
          behavior: SnackBarBehavior.floating,
        ),
      );
      rethrow;
    } finally {
      controller.setLoading(false); // 🔥 STOP LOADING (ALWAYS)
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await AppPrefs.clear();
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
