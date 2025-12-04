import 'package:get/get.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class SplashController extends GetxController{
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Future.delayed(const Duration(seconds: 2), () {
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed(AppRoutes.tabBarScreen);
      });
    });
  }
}