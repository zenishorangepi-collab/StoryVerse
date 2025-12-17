import 'package:get/get.dart';

enum LibraryTab { saved, collections, archive }

enum SortType { recentlyAdded, recentlyListened, progress }

class LibraryController extends GetxController {
  LibraryTab selectedTab = LibraryTab.saved;
  SortType selectedSort = SortType.recentlyListened;

  void changeTab(LibraryTab tab) {
    selectedTab = tab;
    update();
  }

  void changeSort(SortType sort) {
    selectedSort = sort;
    update();
  }
}
