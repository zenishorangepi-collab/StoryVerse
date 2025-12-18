import 'package:get/get.dart';

class PlanController extends GetxController {
  var selectedPlan = '';

  void selectPlan(String name) {
    selectedPlan = name;
    update();
  }
}
