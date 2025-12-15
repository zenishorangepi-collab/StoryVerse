import 'package:get/get.dart';
import 'package:utsav_interview/app/book_details_view/book_details_controller.dart';
import 'package:utsav_interview/app/splash_screen/splash_controller.dart';

class BookDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookDetailsController());
  }
}
