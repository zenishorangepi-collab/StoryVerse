import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/routes/app_routes.dart';

enum SubscriptionPlan { yearly, monthly }

class SubscriptionController extends GetxController {
  SubscriptionPlan selectedPlan = SubscriptionPlan.yearly;

  void selectPlan(SubscriptionPlan plan) {
    if (selectedPlan == plan) return;
    selectedPlan = plan;
    update();
  }

  void onUpgrade() {
    // TODO: purchase logic
  }

  void onContinueFree() {
    Get.offAllNamed(AppRoutes.tabBarScreen);
  }
}
