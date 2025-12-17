import 'package:get/get.dart';
import 'package:utsav_interview/app/library_view/library_controller.dart';

class LibraryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LibraryController>(() => LibraryController());
  }
}
