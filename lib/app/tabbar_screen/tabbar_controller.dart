import 'dart:convert';

import 'package:get/get.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';

class TabBarScreenController extends GetxController {
  int currentIndex = 0;
  bool isSelected = true;

  void onTabTapped(int index) {
    currentIndex = index;

    update();
  }

  Map<String, dynamic>? getUserFromPrefs() {
    final userJson = AppPrefs.getString(CS.keyUserData);

    if (userJson.isEmpty) return null;

    return jsonDecode(userJson) as Map<String, dynamic>;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    final auth = getUserFromPrefs();
    print(auth);
  }
}
