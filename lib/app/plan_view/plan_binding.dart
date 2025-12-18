import 'package:get/get.dart';
import 'package:utsav_interview/app/plan_view/plan_controller.dart';

class PlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlanController>(() => PlanController());
  }
}
