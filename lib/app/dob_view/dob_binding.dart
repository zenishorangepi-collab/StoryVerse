import 'package:get/get.dart';
import 'package:utsav_interview/app/dob_view/dob_controller.dart';

class DobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DobController>(() => DobController());
  }
}
