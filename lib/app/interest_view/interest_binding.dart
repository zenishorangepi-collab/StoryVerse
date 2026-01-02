import 'package:get/get.dart';
import 'package:utsav_interview/app/interest_view/interest_controller.dart';

class InterestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterestController>(() => InterestController());
  }
}
