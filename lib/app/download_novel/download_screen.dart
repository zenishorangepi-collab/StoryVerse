// lib/app/downloads/downloads_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:utsav_interview/app/download_novel/download_controller.dart';
import 'package:utsav_interview/app/download_novel/download_model.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/common_string.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DownloadController>(
      init: DownloadController(),
      builder: (controller) {
        return Scaffold(
          // backgroundColor: AppColors.colorBlack,
          appBar: AppBar(
            backgroundColor: AppColors.colorBgGray02,
            title: Text(CS.vDownloads, style: AppTextStyles.heading20WhiteSemiBold),

            actions: [
              if (controller.downloadedNovels.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    final storage = await controller.getTotalStorageUsed();
                    Get.snackbar(CS.vStorageUsed, storage, snackPosition: SnackPosition.BOTTOM);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.storage, size: 18, color: AppColors.colorWhite),
                      SizedBox(width: 4),
                      FutureBuilder<String>(
                        future: controller.getTotalStorageUsed(),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? '0 B', style: AppTextStyles.body14WhiteMedium);
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
          body:
              controller.downloadedNovels.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_outlined, size: 64, color: AppColors.colorGrey),
                        SizedBox(height: 16),
                        Text(CS.vNoDownloadedNovels, style: AppTextStyles.body16WhiteBold),
                        SizedBox(height: 8),
                        Text(CS.vDownloadNovelsToListenOffline, style: AppTextStyles.body14GreyRegular),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: controller.downloadedNovels.length,
                    itemBuilder: (context, index) {
                      final download = controller.downloadedNovels[index];

                      return Card(
                        color: AppColors.colorChipBackground,
                        margin: EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(download.coverUrl),
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Image.asset(CS.imgBookCover2, width: 50, height: 70, fit: BoxFit.cover);
                              },
                            ),
                          ),
                          title: Text(download.bookName, style: AppTextStyles.body16WhiteBold, maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(download.authorName, style: AppTextStyles.body14GreyRegular),
                              SizedBox(height: 4),
                              Text(
                                '${download.chapters.length} chapters • ${controller.formatBytes(download.totalSize)}',
                                style: AppTextStyles.body12GreyRegular,
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            icon: Icon(Icons.more_vert, color: AppColors.colorWhite),
                            color: AppColors.colorBgGray04,
                            itemBuilder:
                                (_) => [
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, color: AppColors.colorRed),
                                        SizedBox(width: 8),
                                        Text(CS.vDelete, style: AppTextStyles.body14RedRegular),
                                      ],
                                    ),
                                    onTap: () {
                                      Future.delayed(Duration.zero, () {
                                        _showDeleteDialog(context, controller, download.novelId);
                                      });
                                    },
                                  ),
                                ],
                          ),
                          onTap: () {
                            _playOfflineNovel(controller, download);
                          },
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, DownloadController controller, String novelId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.colorBgGray02,
            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actionsAlignment: MainAxisAlignment.end,
            title: Text(CS.vConfirmDeletion, style: AppTextStyles.body16WhiteBold),
            content: Text(CS.vDownloadDeleteWarning, style: AppTextStyles.body14WhiteMedium),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text(CS.vCancel, style: AppTextStyles.body14WhiteMedium)),
              TextButton(
                onPressed: () {
                  Get.back();
                  controller.deleteDownload(novelId);
                },
                child: Text(CS.vDelete, style: AppTextStyles.body14RedBold),
              ),
            ],
          ),
    );
  }

  void _playOfflineNovel(DownloadController controller, DownloadModel download) {
    // Convert DownloadModel to NovelsDataModel for playback
    // You'll need to implement this conversion
    Get.snackbar('Playing Offline', download.bookName, snackPosition: SnackPosition.BOTTOM);

    // Navigate to audio player with offline data
    // Get.toNamed(AppRoutes.audioTextScreen, arguments: {
    //   'novelData': convertToNovelModel(download),
    //   'isOffline': true,
    // });
  }
}
