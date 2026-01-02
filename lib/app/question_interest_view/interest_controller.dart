import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_string.dart';

class InterestController extends GetxController {
  final List<InterestItem> interests = const [
    InterestItem(icon: Icons.auto_fix_high, title: CS.vFantasy),
    InterestItem(icon: Icons.favorite_border, title: CS.vRomance),
    InterestItem(icon: Icons.science_outlined, title: CS.vScienceFiction),
    InterestItem(icon: Icons.search, title: CS.vMysteryThriller),
    InterestItem(icon: Icons.explore_outlined, title: CS.vActionAdventure),
    InterestItem(icon: Icons.public, title: CS.vDystopia),
    InterestItem(icon: Icons.business_center_outlined, title: CS.vBusinessEconomics),
    InterestItem(icon: Icons.memory_outlined, title: CS.vTechnology),
  ];

  final Set<int> selectedIndexes = {};

  void toggleSelection(int index) {
    if (selectedIndexes.contains(index)) {
      selectedIndexes.remove(index);
    } else {
      selectedIndexes.add(index);
    }
    update();
  }

  bool get isContinueEnabled => selectedIndexes.length >= 3;
}

// -------------------- MODEL --------------------
class InterestItem {
  final IconData icon;
  final String title;

  const InterestItem({required this.icon, required this.title});
}
