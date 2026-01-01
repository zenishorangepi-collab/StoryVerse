import 'package:get/get.dart';
import 'package:utsav_interview/app/collection_view/collection_controller.dart';

class CollectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CollectionController());
  }
}
