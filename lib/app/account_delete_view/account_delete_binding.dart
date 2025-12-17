import 'package:get/get.dart';
import 'package:utsav_interview/app/account_delete_view/account_delete_controller.dart';

class DeleteAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeleteAccountController>(() => DeleteAccountController());
  }
}
