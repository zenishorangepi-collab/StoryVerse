import 'package:get/get.dart';
import 'package:utsav_interview/app/splash_screen/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
  }
}
