import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:utsav_interview/app/auth_options_view/authoptions_controller.dart';
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
  static Future<UserCredential?> signInWithGoogle(context) async {
    AuthOptionsController controller = Get.find<AuthOptionsController>();

    try {
      initSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;
      GoogleSignInClientAuthorization? authorization = await authorizationClient.authorizationForScopes(['email', 'profile']);
      final accessToken = authorization?.accessToken;

      if (accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.colorBgChipContainer,
            content: Row(
              spacing: 10,
              children: [Icon(Icons.error_outline, color: AppColors.colorRed), Text("Login failed", style: AppTextStyles.bodyMediumRedBold)],
            ),
            duration: const Duration(seconds: 2),
            // width: 280.0,
            // Width of the SnackBar.,
            padding: const EdgeInsets.all(10),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          ),
        );
        final authorization2 = await authorizationClient.authorizationForScopes(['email', 'profile']);
        if (authorization2?.accessToken == null) {
          throw FirebaseAuthException(code: "error", message: "error");
        }
        authorization = authorization2;
      } else {
        AppPrefs.setBool(CS.keyIsLoginIn, true);
        Get.offAllNamed(AppRoutes.tabBarScreen);
      }
      final credential = GoogleAuthProvider.credential(accessToken: accessToken, idToken: idToken);
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      print(user);
      if (user != null) {
        await controller.saveUserAsMap(uid: user.uid, email: user.email ?? '', name: user.displayName ?? '', photoUrl: user.photoURL);
      }
      // if (user != null) {
      //   final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      //   final docSnapshot = await userDoc.get();
      //   if (!docSnapshot.exists) {
      //     await userDoc.set({
      //       'uid': user.uid,
      //       'name': user.displayName ?? '',
      //       'email': user.email ?? '',
      //       'photoURL': user.photoURL ?? '',
      //       'provider': 'google',
      //       'createdAt': FieldValue.serverTimestamp(),
      //     });
      //   }
      // }
      return userCredential;
    } catch (e) {
      print('Error: $e');
      rethrow;
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
