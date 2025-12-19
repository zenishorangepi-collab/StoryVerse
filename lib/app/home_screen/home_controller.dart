import 'dart:convert';

import 'package:get/get.dart';
import 'package:utsav_interview/app/home_screen/models/home_model.dart';
import 'package:utsav_interview/app/home_screen/models/recent_listen_model.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';

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
  List<RecentViewModel> listRecents = <RecentViewModel>[];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getRecentList();
  }

  getRecentList() async {
    // await clearRecentViews();
    listRecents = await getRecentViews();
    update();
  }

  Future<void> clearRecentViews() async {
    AppPrefs.remove(CS.keyRecentViews);
  }

  Future<List<RecentViewModel>> getRecentViews() async {
    List<String> recentList = AppPrefs.getStringList(CS.keyRecentViews) ?? [];

    // convert JSON to model
    List<RecentViewModel> items = recentList.map((item) => RecentViewModel.fromJson(jsonDecode(item))).toList();

    // reverse to show latest first
    return items.reversed.toList();
  }

  String formatReadableLength(String rawTime) {
    List<String> parts = rawTime.split(':');

    // mm:ss format → Xm Ys
    if (parts.length == 2) {
      int minutes = int.parse(parts[0]);
      int seconds = int.parse(parts[1]);

      String result = "";

      if (minutes > 0) result += "${minutes}m ";
      if (seconds > 0) result += "${seconds}s";

      return result.trim();
    }

    // hh:mm:ss format → Hh MMm SSs
    if (parts.length == 3) {
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      int seconds = int.parse(parts[2]);

      String result = "";

      if (hours > 0) result += "${hours}h ";
      if (minutes > 0) result += "${minutes}m ";
      if (seconds > 0) result += "${seconds}s";

      return result.trim();
    }

    return rawTime;
  }
}
