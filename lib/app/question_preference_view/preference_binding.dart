import 'package:get/get.dart';
import 'package:utsav_interview/app/question_preference_view/preference_controller.dart';

class PreferenceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PreferenceController>(() => PreferenceController());
  }
}
