import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';

class AddToCollectionController extends GetxController {
  TextEditingController searchController = TextEditingController();
  final Set<String> selectedIds = {};
  RxList<NovelsDataModel> listNovelData = <NovelsDataModel>[].obs;
  final List<NovelsDataModel> _originalList = [];
  final List<NovelsDataModel> listSelectedNovel = [];
  bool isDataLoading = false;
  String collectionId = "";

  bool get isButtonEnabled => selectedIds.isNotEmpty;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (Get.arguments != null) {
      collectionId = Get.arguments;
    }

    fetchNovels();
    searchController.addListener(_onSearch);
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
}
