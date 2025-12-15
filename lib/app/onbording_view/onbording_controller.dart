import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();

  final RxInt currentIndex = 0.obs;

  final int totalPages = 4;

  void onPageChanged(int index) {
    currentIndex.value = index;
    update();
  }

  void nextPage() {
    if (currentIndex.value < totalPages - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Get.offAllNamed(AppRoutes.authOptionsScreen);
    }
    update();
  }

  void skip() {
    pageController.jumpToPage(totalPages - 1);
    update();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
