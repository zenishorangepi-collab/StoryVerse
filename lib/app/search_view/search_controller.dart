import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/home_screen/home_controller.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';

import '../library_view/library_controller.dart';

class SearchScreenController extends GetxController {
  TextEditingController searchController = TextEditingController();
  List<NovelsDataModel> listNovel = <NovelsDataModel>[];
  List<NovelsDataModel> originalList = [];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (Get.arguments != null) {
      getSavedList();
    } else {
      final homeController = Get.find<HomeController>();

      originalList = List<NovelsDataModel>.from(homeController.listNovelData);

      listNovel = List<NovelsDataModel>.from(originalList);
    }
    // for (var element in listNovel) {
    //   originalList.add(element);
    // }
    searchController.addListener(_onSearch);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    searchController.dispose();
    originalList.clear();
    originalList.clear();
    super.onClose();
  }

  Future<void> getSavedList() async {
    final controller = Get.find<LibraryController>();

    final List<NovelsDataModel> data = await controller.getRecentViews();

    originalList = List<NovelsDataModel>.from(data);
    listNovel = List<NovelsDataModel>.from(data);

    update();
  }

  void _onSearch() {
    final query = searchController.text.toLowerCase().trim().removeAllWhitespace;

    listNovel.clear();

    if (query.isEmpty) {
      listNovel.addAll(originalList);
    } else {
      for (final book in originalList) {
        final name = book.bookName?.toLowerCase().removeAllWhitespace ?? '';
        final author = book.author?.name?.toLowerCase().removeAllWhitespace ?? '';

        if (name.contains(query) || author.contains(query)) {
          listNovel.add(book);
        }
      }
    }
    update();
  }
}
