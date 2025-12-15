import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class AuthOptionsController extends GetxController {
  Future<void> signInAsGuest() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();

      final user = userCredential.user;

      if (user != null) {
        print('Guest UID: ${user.uid}');
        // Navigate to Home
        Get.offAllNamed(AppRoutes.tabBarScreen);
      }
    } catch (e) {
      print('Guest login failed: $e');
    }
  }
}
