import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/create_collection_view/create_collection_model.dart';
import 'package:utsav_interview/app/home_screen/home_controller.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';

class AddToCollectionController extends GetxController {
  TextEditingController searchController = TextEditingController();
  final Set<String> selectedIds = {};
  List<CollectionModel> listCollection = [];
  RxList<NovelsDataModel> listNovelData = <NovelsDataModel>[].obs;
  List<NovelsDataModel> _originalList = [];
  final List<NovelsDataModel> listSelectedNovel = [];

  bool isDataLoading = false;
  String collectionId = "";
  NovelsDataModel? novelData = NovelsDataModel();

  bool get isButtonEnabled => selectedIds.isNotEmpty;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (Get.arguments != null) {
      final args = Get.arguments;

      collectionId = (args is Map && args['collectionId'] != null) ? args['collectionId'] : '';

      novelData = (args is Map) ? args['novelData'] : null;
    }

    if (collectionId.isNotEmpty) {
      getNovelsByCollectionData();
    }

    fetchNovels();
    getCollection();

    searchController.addListener(_onSearch);
  }

  Future<List<CollectionModel>> getAllCollections() async {
    final jsonList = AppPrefs.getStringList(CS.keyCollections);
    return jsonList.map((json) => CollectionModel.fromJson(jsonDecode(json))).toList();
  }

  void addCollection(CollectionModel collection) {
    listCollection.add(collection);
    update();
  }

  getCollection() async {
    listCollection.clear();
    listCollection = await getAllCollections();
    update();
  }

  Future<void> fetchNovels() async {
    isDataLoading = true;
    update();
    listNovelData.clear();
    _originalList.clear();

    final querySnapshot = await FirebaseFirestore.instance.collection('novels').get();

    for (final doc in querySnapshot.docs) {
      final novel = NovelsDataModel.fromJson(doc.data());
      _originalList.add(novel);
    }

    // UI list uses the same data
    listNovelData.addAll(_originalList);
    isDataLoading = false;
    update();
  }

  getNovelsByCollectionData() async {
    List<NovelsDataModel> listCollectionNovel = [];
    listCollectionNovel.clear();
    listCollectionNovel = await getNovelsByCollectionId(collectionId);
    for (var element in listCollectionNovel) {
      selectedIds.add(element.id ?? "");
      listSelectedNovel.add(element);
    }
    update();
  }

  Future<List<NovelsDataModel>> getNovelsByCollectionId(String collectionId) async {
    final raw = AppPrefs.getString(CS.keyCollectionBooks);

    if (raw.isEmpty) return [];

    final Map<String, dynamic> data = jsonDecode(raw);
    final List list = data[collectionId] ?? [];

    return list.map((e) => NovelsDataModel.fromJson(e)).toList();
  }

  void _onSearch() {
    final query = searchController.text.toLowerCase().trim().removeAllWhitespace;

    listNovelData.clear();

    if (query.isEmpty) {
      listNovelData.addAll(_originalList);
    } else {
      for (final book in _originalList) {
        final name = book.bookName?.toLowerCase().removeAllWhitespace ?? '';
        final author = book.author?.name?.toLowerCase().removeAllWhitespace ?? '';

        if (name.contains(query) || author.contains(query)) {
          listNovelData.add(book);
        }
      }
    }
    update();
  }

  Future<void> saveNovelToCollection({required String collectionId, required NovelsDataModel novel}) async {
    Map<String, dynamic> data = {};

    final stored = AppPrefs.getString(CS.keyCollectionBooks);

    if (stored.isNotEmpty) {
      data = jsonDecode(stored);
    }

    final List<dynamic> list = List<dynamic>.from(data[collectionId] ?? []);

    // prevent duplicate
    if (!list.any((e) => e['id'] == novel.id)) {
      list.add(novel.toJson());
    }

    data[collectionId] = list;

    await AppPrefs.setString(CS.keyCollectionBooks, jsonEncode(data));
  }

  /// Add a novel to a specific collection
  Future<void> addNovelToCollection({required String collectionId, required String novelId, required NovelsDataModel novel}) async {
    try {
      final raw = AppPrefs.getString(CS.keyCollectionBooks);

      Map<String, dynamic> data = {};

      if (raw.isNotEmpty) {
        data = jsonDecode(raw) as Map<String, dynamic>;
      }

      final List<Map<String, dynamic>> existingBooks = (data[collectionId] as List?)?.cast<Map<String, dynamic>>() ?? [];

      final bool alreadyExists = existingBooks.any((book) => book['id']?.toString() == novelId);

      if (alreadyExists) {
        return;
      }

      existingBooks.add(novel.toJson());

      data[collectionId] = existingBooks;

      // Save
      await AppPrefs.setString(CS.keyCollectionBooks, jsonEncode(data));
    } catch (e) {
      Get.snackbar('Error', 'Failed to add book to collection', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
