import 'package:get/get.dart';
import 'package:utsav_interview/app/tabbar_screen/tabbar_controller.dart';

class TabBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TabBarScreenController>(() => TabBarScreenController());
  }
}
