import 'package:get/get.dart';
import 'package:utsav_interview/app/add_collection_view/add_collection_controller.dart';

class AddToCollectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AddToCollectionController());
  }
}
