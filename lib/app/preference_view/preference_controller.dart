import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/common_string.dart';

class PreferenceController extends GetxController {
  int? selectedIndex;

  final List<PreferenceItem> items = const [
    PreferenceItem(icon: Icons.menu_book_outlined, title: CS.vBooks),
    PreferenceItem(icon: Icons.public_outlined, title: CS.vNewsStories),
    PreferenceItem(icon: Icons.school_outlined, title: CS.vStudyMaterials),
    PreferenceItem(icon: Icons.newspaper_outlined, title: CS.vBlogsNewsletters),
    PreferenceItem(icon: Icons.science_outlined, title: CS.vJournalsResearch),
    PreferenceItem(icon: Icons.upload_file_outlined, title: CS.vMyImportedContent),
  ];

  void selectItem(int index) {
    selectedIndex = index;
    update();
  }

  bool get isContinueEnabled => selectedIndex != null;
}

class PreferenceItem {
  final IconData icon;
  final String title;

  const PreferenceItem({required this.icon, required this.title});
}
