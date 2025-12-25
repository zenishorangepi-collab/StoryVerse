import 'dart:convert';

import 'package:get/get.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/pref.dart';

enum LibraryTab { saved, collections, archive }

enum SortType { recentlyAdded, recentlyListened, progress }

class LibraryController extends GetxController {
  LibraryTab selectedTab = LibraryTab.saved;
  SortType selectedSort = SortType.recentlyListened;
  List<NovelsDataModel> listRecents = <NovelsDataModel>[];

  RxList<String> archivedBookIds = <String>[].obs;
  List<NovelsDataModel> savedRecents = [];
  List<NovelsDataModel> archivedRecents = [];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    archivedBookIds.value = AppPrefs.getStringList(CS.keyArchivedBookIds) ?? [];
    loadRecents();
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
