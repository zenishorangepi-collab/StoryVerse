import 'package:get/get.dart';
import 'package:utsav_interview/app/sound_spaces_view/sound_spaces_controller.dart';
import 'package:utsav_interview/app/voice_view/voice_controller.dart';

class VoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VoiceController>(() => VoiceController());
  }
}
