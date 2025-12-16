import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
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

  UserModel? getUserFromPrefs() {
    final String? userJson = AppPrefs.getString(CS.keyUserData);

    if (userJson == null || userJson.isEmpty) return null;

    try {
      return UserModel.fromMap(jsonDecode(userJson));
    } catch (e) {
      debugPrint('User parse error: $e');
      return null;
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    userData = getUserFromPrefs();
    print(userData);
  }
}
