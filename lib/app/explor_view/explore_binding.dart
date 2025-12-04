import 'package:get/get.dart';
import 'explore_controller.dart';

class ExploreScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExploreScreenController>(() => ExploreScreenController());
  }
}
