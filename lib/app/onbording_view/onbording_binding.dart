import 'package:get/get.dart';
import 'package:utsav_interview/app/onbording_view/onbording_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
