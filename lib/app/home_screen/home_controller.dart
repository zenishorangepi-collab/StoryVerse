import 'package:get/get.dart';
import 'package:utsav_interview/app/home_screen/models/home_model.dart';

class HomeController extends GetxController {
  List<CategoryItem> dummyCategoryList = [
    CategoryItem(
      image1: "https://picsum.photos/200/300",
      image2: "https://picsum.photos/200/301",
      title: "Fairy Tales and Folklore",
      description: "Enchanted lands, magical beings, timeless traditions",
    ),
    CategoryItem(
      image1: "https://picsum.photos/200/302",
      image2: "https://picsum.photos/200/303",
      title: "Cottage Stories",
      description: "Cozy stories inspired by countryside living",
    ),
  ];
}
