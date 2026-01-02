import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/download_novel/download_controller.dart';

class DownloadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DownloadController>(() => DownloadController());
  }
}
