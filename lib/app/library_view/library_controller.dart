import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/create_collection_view/create_collection_model.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';

enum LibraryTab { saved, collections, archive }

enum SortType { recentlyAdded, recentlyListened, progress }

IconData icon(iconType) {
  switch (iconType) {
    case 'folder':
      return Icons.folder_outlined;
    case 'bookmark':
      return Icons.bookmark_outline;
    case 'edit':
      return Icons.edit_outlined;
    case 'article':
      return Icons.article_outlined;
    case 'mic':
      return Icons.mic_outlined;
    case 'photo':
      return Icons.photo_outlined;
    case 'star':
      return Icons.star_outline;
    case 'palette':
      return Icons.palette_outlined;
    case 'music':
      return Icons.music_note_outlined;
    case 'restaurant':
      return Icons.restaurant_outlined;
    default:
      return Icons.folder_outlined;
  }
}

class LibraryController extends GetxController {
  LibraryTab selectedTab = LibraryTab.saved;
  SortType selectedSort = SortType.recentlyListened;
  List<NovelsDataModel> listRecents = <NovelsDataModel>[];
  RxList<String> archivedBookIds = <String>[].obs;
  List<NovelsDataModel> savedRecents = [];
  List<NovelsDataModel> archivedRecents = [];
  List<CollectionModel> listCollection = [];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    archivedBookIds.value = AppPrefs.getStringList(CS.keyArchivedBookIds) ?? [];
    getCollection();
    loadRecents();
  }

  void addCollection(CollectionModel collection) {
    listCollection.add(collection);
    update();
  }
  void updateCollection(CollectionModel updatedCollection) {
    final index = listCollection.indexWhere((c) => c.id == updatedCollection.id);
    if (index != -1) {
      listCollection[index] = updatedCollection;
      update();
    }
  }
  Future<List<CollectionModel>> getAllCollections() async {
    final jsonList = AppPrefs.getStringList(CS.keyCollections);
    return jsonList.map((json) => CollectionModel.fromJson(jsonDecode(json))).toList();
  }

  getCollection() async {
    listCollection.clear();
    listCollection = await getAllCollections();
    update();
  }

  Future<void> loadRecents() async {
    final List<NovelsDataModel> listRecents = await getRecentViews() ?? [];

    final Set<String> recentBookIds = listRecents.where((b) => b.id != null).map((b) => b.id!).toSet();

    archivedBookIds.value = AppPrefs.getStringList(CS.keyArchivedBookIds) ?? [];

    archivedBookIds.removeWhere((id) => !recentBookIds.contains(id));

    AppPrefs.setStringList(CS.keyArchivedBookIds, archivedBookIds);

    savedRecents.clear();
    archivedRecents.clear();

    savedRecents = listRecents.where((b) => b.id != null && !archivedBookIds.contains(b.id)).toList();

    archivedRecents = listRecents.where((b) => b.id != null && archivedBookIds.contains(b.id)).toList();

    update();
  }

  void changeTab(LibraryTab tab) {
    selectedTab = tab;
    update();
  }

  void changeSort(SortType sort) {
    selectedSort = sort;
    update();
  }

  Future<List<NovelsDataModel>> getRecentViews() async {
    final recentList = AppPrefs.getStringList(CS.keyRecentViews) ?? [];

    final items = <NovelsDataModel>[];
    for (final item in recentList) {
      items.add(NovelsDataModel.fromJson(jsonDecode(item)));
    }

    return items;
  }

  void _saveArchivedIds() {
    AppPrefs.setStringList(CS.keyArchivedBookIds, archivedBookIds);
    loadRecents();
    update();
  }

  /// Archive book
  void archiveBook(String bookId) {
    if (bookId.isEmpty) return;

    archivedBookIds.add(bookId);
    savedRecents.removeWhere((b) => b.id == bookId);

    _saveArchivedIds();

    update();
  }

  void unArchiveBook(String bookId) {
    if (bookId.isEmpty) return;

    archivedBookIds.remove(bookId);

    archivedRecents.removeWhere((b) => b.id == bookId);

    _saveArchivedIds();
    update();
  }

  bool isArchived(String bookId) {
    return archivedBookIds.contains(bookId);
  }
}
