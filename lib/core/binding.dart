import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Register global audio controller
    Get.put(AudioTextController(), permanent: true);
  }
}
