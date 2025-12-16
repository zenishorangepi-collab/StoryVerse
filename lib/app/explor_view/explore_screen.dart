import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'explore_controller.dart';

class ExploreScreen extends GetView<ExploreScreenController> {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Coming Soon...", style: AppTextStyles.heading28WhiteBold)));
  }
}
