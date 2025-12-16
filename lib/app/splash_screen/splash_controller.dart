import 'package:get/get.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    bool isLoggedIn = AppPrefs.getBool(CS.keyIsLoginIn);
    Future.delayed(const Duration(seconds: 2), () {
      isLoggedIn ? Get.offAllNamed(AppRoutes.tabBarScreen) : Get.offAllNamed(AppRoutes.onboardingScreen);
      // Get.offAllNamed(AppRoutes.onboardingScreen);
    });
  }
}
