import 'package:get/get.dart';
import 'package:utsav_interview/app/referral_view/referral_controller.dart';

class ReferralBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReferralController>(() => ReferralController());
  }
}
