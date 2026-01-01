import 'dart:convert';

import 'package:get/get.dart';
import 'package:utsav_interview/app/create_collection_view/create_collection_model.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
import 'package:utsav_interview/app/library_view/library_controller.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';

class CollectionController extends GetxController {
  final Set<String> selectedBookIds = {};
  CollectionModel? collection;
  RxList<NovelsDataModel> listNovelData = <NovelsDataModel>[].obs;

  void toggleSelection(String id) {
    if (selectedBookIds.contains(id)) {
      selectedBookIds.remove(id);
    } else {
      selectedBookIds.add(id);
    }
    update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (Get.arguments != null) {
      collection = Get.arguments;
    }
    getNovelData();
  }

  Future<List<CollectionModel>> getAllCollections() async {
    final jsonList = AppPrefs.getStringList(CS.keyCollections);
    return jsonList.map((json) => CollectionModel.fromJson(jsonDecode(json))).toList();
  }

  // Delete collection
  Future<void> deleteCollection(String collectionId) async {
    try {
      List<CollectionModel> collections = await getAllCollections();
      collections.removeWhere((c) => c.id == collectionId);

      final jsonList = collections.map((c) => jsonEncode(c.toJson())).toList();
      await AppPrefs.setStringList(CS.keyCollections, jsonList);
      final libraryController = Get.find<LibraryController>();
      libraryController.getCollection();
      Get.back();
    } catch (e) {}
  }

  getNovelData() async {
    listNovelData.clear();
    listNovelData.value = await getNovelsByCollectionId(collection?.id ?? "");

    update();
  }

  Future<List<NovelsDataModel>> getNovelsByCollectionId(String collectionId) async {
    final raw = AppPrefs.getString(CS.keyCollectionBooks);

    if (raw.isEmpty) return [];

    final Map<String, dynamic> data = jsonDecode(raw);
    final List list = data[collectionId] ?? [];

    return list.map((e) => NovelsDataModel.fromJson(e)).toList();
  }

  Future<void> removeNovelFromCollection({required String collectionId, required String novelId}) async {
    final raw = AppPrefs.getString(CS.keyCollectionBooks);

    final Map<String, dynamic> data = jsonDecode(raw);
    final List list = data[collectionId] ?? [];

    list.removeWhere((e) => e['id'] == novelId);

    data[collectionId] = list;

    await AppPrefs.setString(CS.keyCollectionBooks, jsonEncode(data));
    getNovelData();
  }
}
