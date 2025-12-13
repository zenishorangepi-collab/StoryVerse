import 'package:get/get.dart';
import 'package:utsav_interview/app/auth_options_view/authoptions_controller.dart';

class AuthOptionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthOptionsController>(() => AuthOptionsController());
  }
}
