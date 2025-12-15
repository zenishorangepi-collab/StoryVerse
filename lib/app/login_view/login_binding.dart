import 'package:get/get.dart';
import 'package:utsav_interview/app/login_view/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
