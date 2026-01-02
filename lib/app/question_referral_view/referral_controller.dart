import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/common_string.dart';

class ReferralController extends GetxController {
  int? selectedIndex;

  final List<ReferralItem> sources = const [
    ReferralItem(icon: Icons.music_note, title: CS.vTiktok),
    ReferralItem(icon: Icons.camera_alt_outlined, title: CS.vInstagram),
    ReferralItem(icon: Icons.search, title: CS.vGoogleSearch),
    ReferralItem(icon: Icons.email_outlined, title: CS.vEmailNewsletter),
    ReferralItem(icon: Icons.shop_outlined, title: CS.vAppStorePlayStore),
    ReferralItem(icon: Icons.headphones_outlined, title: CS.vPodcast),
    ReferralItem(icon: Icons.facebook, title: CS.vFacebook),
    ReferralItem(icon: Icons.group_outlined, title: CS.vFriendsFamily),
    ReferralItem(icon: Icons.play_circle_outline, title: CS.vYoutube),
  ];

  void selectSource(int index) {
    selectedIndex = index;
    update();
  }

  bool get isContinueEnabled => selectedIndex != null;
}

// -------------------- MODEL --------------------
class ReferralItem {
  final IconData icon;
  final String title;

  const ReferralItem({required this.icon, required this.title});
}
