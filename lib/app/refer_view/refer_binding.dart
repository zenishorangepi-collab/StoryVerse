import 'package:get/get.dart';
import 'package:utsav_interview/app/refer_view/refer_controller.dart';

class ReferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReferController>(() => ReferController());
  }
}
