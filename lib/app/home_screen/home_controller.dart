import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/home_screen/models/categories_model.dart';
import 'package:utsav_interview/app/home_screen/models/home_model.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
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
  RxList<NovelsDataModel> listNovelData = <NovelsDataModel>[].obs;
  RxList<CategoriesDataModel> listNovelCategoriesData = <CategoriesDataModel>[].obs;
  bool isDataLoading = false;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchData();
    getRecentList();
  }

  fetchData() async {
    await fetchNovelCategories();
    await fetchNovels();
  }

  fetchNovels() async {
    listNovelData.clear();
    final querySnapshot = await FirebaseFirestore.instance.collection('novels').get();

    for (final doc in querySnapshot.docs) {
      print(doc.id);
      final data = doc.data();
      final novel = NovelsDataModel.fromJson(data);
      listNovelData.add(novel);
    }
  }

  fetchNovelCategories() async {
    listNovelCategoriesData.clear();
    final querySnapshot = await FirebaseFirestore.instance.collection('categories').get();

    for (final doc in querySnapshot.docs) {
      print(doc.id);
      final data = doc.data();
      final novelCategory = CategoriesDataModel.fromJson(data);
      listNovelCategoriesData.add(novelCategory);

      update();
    }
  }

  // Get novels for a specific category
  List<NovelsDataModel> getNovelsForCategory(String categoryId, String categoryName) {
    return listNovelData.where((novel) {
      if (novel.categories == null || novel.categories!.isEmpty) return false;
      return novel.categories!.any((cat) => cat.id == categoryId || cat.name == categoryName);
    }).toList();
  }

  // Get only categories that have novels
  List<CategoriesDataModel> getActiveCategoriesOnly() {
    return listNovelCategoriesData.where((category) {
      final novelsInCategory = getNovelsForCategory(category.id ?? '', category.name ?? '');
      return novelsInCategory.isNotEmpty;
    }).toList();
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
}
