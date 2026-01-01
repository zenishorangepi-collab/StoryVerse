import 'package:get/get.dart';
import 'package:utsav_interview/app/create_collection_view/create_collection_controller.dart';

class CreateCollectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateCollectionController>(() => CreateCollectionController());
  }
}
