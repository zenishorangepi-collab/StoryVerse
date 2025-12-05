import 'package:get/get.dart';
import 'package:utsav_interview/app/sound_spaces_view/sound_spaces_controller.dart';

class SoundSpacesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SoundSpacesController>(() => SoundSpacesController());
  }
}
