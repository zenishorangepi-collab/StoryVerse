import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/tabbar_screen/tabbar_controller.dart';

class DeleteAccountController extends GetxController {
  // Controller for the email input field
  final emailInputController = TextEditingController();

  // The expected email (from your image)
  String targetEmail = "";

  // Observable to track if the button should be enabled
  var isButtonEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    targetEmail = userData?.email ?? "";
    // Listen to text changes to validate the button state
    emailInputController.addListener(() {
      isButtonEnabled.value = emailInputController.text == targetEmail;
      update();
    });
  }

  void deleteAccount() {
    if (isButtonEnabled.value) {
      Get.snackbar("Action", "Account deletion initiated", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    emailInputController.dispose();
    super.onClose();
  }
}
