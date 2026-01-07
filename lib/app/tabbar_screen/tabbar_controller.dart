import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';
import 'package:utsav_interview/app/tabbar_screen/user_data_model.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';

UserModel? userData;

class TabBarScreenController extends GetxController {
  int currentIndex = 0;
  bool isSelected = true;

  void onTabTapped(int index) {
    currentIndex = index;

    update();
  }

  getUserFromPrefs() {
    // Get user data from preferences
    String? userJson = AppPrefs.getString(CS.keyUserData);
    if(userJson.isNotEmpty) {
      userData = UserModel.fromJson(jsonDecode(userJson));
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getUserFromPrefs();

    print(userData);
  }
}
