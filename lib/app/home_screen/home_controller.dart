import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/home_screen/models/categories_model.dart';
import 'package:utsav_interview/app/home_screen/models/home_model.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';


RxList<NovelsDataModel> listRecents = <NovelsDataModel>[].obs;

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

  RxList<NovelsDataModel> listNovelData = <NovelsDataModel>[].obs;
  RxList<CategoriesDataModel> listNovelCategoriesData = <CategoriesDataModel>[].obs;
  bool isDataLoading = false;
  bool isTimeout = false;
  Timer? _timeoutTimer;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // fetchData();
    getRecentList();
    fetchDataWithTimeout();
  }
  @override
  void onClose() {
    _timeoutTimer?.cancel();
    super.onClose();
  }
  Future<void> fetchDataWithTimeout() async {
    isTimeout = false;
    update();

    // Start timeout timer
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (listNovelCategoriesData.isEmpty) {
        isTimeout = true;
        update();
      }
    });

    // Fetch data
    await fetchData();

    // Cancel timeout if data loaded
    _timeoutTimer?.cancel();
  }

  void retryFetch() {
    fetchDataWithTimeout();
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
    listRecents.value = await getRecentViews();
    update();
  }

  Future<void> clearRecentViews() async {
    AppPrefs.remove(CS.keyRecentViews);
  }

  Future<List<NovelsDataModel>> getRecentViews() async {
    final recentList = AppPrefs.getStringList(CS.keyRecentViews) ?? [];

    final items = <NovelsDataModel>[];
    for (final item in recentList) {
      items.add(NovelsDataModel.fromJson(jsonDecode(item)));
    }

    return items;
  }
}
