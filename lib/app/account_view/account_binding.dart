import 'package:get/get.dart';
import 'package:utsav_interview/app/account_view/account_controller.dart';

class AccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountController>(() => AccountController());
  }
}
