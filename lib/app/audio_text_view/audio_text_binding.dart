import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';

class AudioTextBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AudioTextController());
  }
}
