import 'package:get/get.dart';

class TabBarScreenController extends GetxController {
  int currentIndex = 0;
  bool isSelected=true;

  void onTabTapped(int index) {

    if (index == 2) {
      Get.toNamed('/add');
      return;
    }
    currentIndex = index;

    update();
  }
}
