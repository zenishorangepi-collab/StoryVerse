import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/download_novel/download_service.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
import 'package:utsav_interview/app/library_view/library_screen.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/pref.dart';

class DownloadController extends GetxController {
  List<NovelsDataModel> downloadedNovels = [];
  bool isDownloading = false;
  double downloadProgress = 0.0;
  String currentDownloadingId = '';

  @override
  void onInit() {
    super.onInit();
    loadDownloadedNovels();
  }

  /// Load all downloaded novels from preferences
  Future<void> loadDownloadedNovels() async {
    try {
      final jsonList = AppPrefs.getStringList(CS.keyDownloads);
      downloadedNovels = jsonList.map((json) => NovelsDataModel.fromJson(jsonDecode(json))).toList();
      update();
    } catch (e) {
      debugPrint('❌ Error loading downloads: $e');
    }
  }

  /// Check if novel is downloaded
  bool isNovelDownloaded(String novelId) {
    return downloadedNovels.any((d) => d.id == novelId);
  }

  /// Download entire novel (all chapters)
  Future<void> downloadNovel(NovelsDataModel novel) async {
    if (isDownloading) {
      Get.snackbar(CS.vInfo, CS.vAlreadyDownloading, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (isNovelDownloaded(novel.id ?? '')) {
      Get.snackbar(CS.vInfo, CS.vNovelAlreadyDownloaded, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    showDownloadProgressDialog();

    try {
      isDownloading = true;
      currentDownloadingId = novel.id ?? '';
      downloadProgress = 0.0;
      update();

      final chapters = novel.audioFiles ?? [];
      if (chapters.isEmpty) {
        throw Exception(CS.vNoChaptersFound);
      }

      List<AudioFiles> downloadedChapters = [];
      int totalSize = 0;

      // Download each chapter
      for (int i = 0; i < chapters.length; i++) {
        final chapter = chapters[i];

        // Update progress
        final baseProgress = i / chapters.length;
        downloadProgress = baseProgress;
        update();

        // Download audio
        final audioPath = await DownloadService.downloadAudio(
          url: chapter.url ?? '',
          novelId: novel.id ?? '',
          chapterId: chapter.id ?? '',
          onProgress: (chapterProgress) {
            downloadProgress = baseProgress + (chapterProgress * 0.4 / chapters.length);
            update();
          },
        );

        // Download text/transcript
        final textPath = await DownloadService.downloadText(url: chapter.audioJsonUrl ?? '', novelId: novel.id ?? '', chapterId: chapter.id ?? '');

        // Get file sizes
        final audioSize = await DownloadService.getFileSize(audioPath);
        final textSize = await DownloadService.getFileSize(textPath);
        totalSize += audioSize + textSize;

        downloadedChapters.add(
          AudioFiles(
            duration: chapter.duration,
            id: chapter.id ?? '',
            name: chapter.name ?? 'Chapter ${i + 1}',
            url: chapter.url,
            fileAudioUrl: audioPath,
            audioJsonUrl: chapter.audioJsonUrl,
            fileAudioTextJsonUrl: textPath,
            chapterIndex: i,
            size: audioSize + textSize,
          ),
        );
      }

      // Download cover
      final coverPath = await DownloadService.downloadCover(url: novel.bookCoverUrl ?? '', novelId: novel.id ?? '');

      // Create download model
      final download = NovelsDataModel(
        id: novel.id ?? '',
        bookName: novel.bookName ?? '',
        author: novel.author,
        bookCoverUrl: novel.bookCoverUrl,
        fileBookCoverUrl: coverPath,
        summary: novel.summary ?? '',
        totalAudioLength: novel.totalAudioLength ?? 0.0,
        language: novel.language,
        audioFiles: downloadedChapters,
        categories: novel.categories,
        createdAt: novel.createdAt,
        publishedDate: novel.publishedDate,
        updatedAt: novel.updatedAt,
        totalSize: totalSize,
      );

      // Save to preferences
      await _saveDownload(download);

      downloadProgress = 1.0;
      update();
      Get.back();
      Get.snackbar(
        "",
        CS.vNovelDownloadedSuccessfully,
        snackPosition: SnackPosition.BOTTOM,
        // backgroundColor: AppColors.colorGreen,
        titleText: Text(CS.vSuccess, style: AppTextStyles.body16GreenMedium),
        colorText: AppColors.colorWhite,
      );
    } catch (e) {
      debugPrint('❌ Error downloading novel: $e');
      Get.back();
      Get.snackbar(
        CS.vError,
        '${CS.vFailedDownloadNovel}: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.colorRed,
        colorText: AppColors.colorWhite,
      );
    } finally {
      isDownloading = false;
      currentDownloadingId = '';
      downloadProgress = 0.0;
      update();
    }
  }

  /// Save download to preferences
  Future<void> _saveDownload(NovelsDataModel download) async {
    downloadedNovels.add(download);
    final jsonList = downloadedNovels.map((d) => jsonEncode(d.toJson())).toList();
    await AppPrefs.setStringList(CS.keyDownloads, jsonList);
  }

  /// Delete downloaded novel
  Future<void> deleteDownload(String novelId) async {
    try {
      // Delete files
      await DownloadService.deleteDownload(novelId);

      // Remove from list
      downloadedNovels.removeWhere((d) => d.id == novelId);

      // Update preferences
      final jsonList = downloadedNovels.map((d) => jsonEncode(d.toJson())).toList();
      await AppPrefs.setStringList(CS.keyDownloads, jsonList);

      update();
      Get.back();
      Get.snackbar(
        "",
        CS.vNovelDeletedSuccessfully,
        snackPosition: SnackPosition.BOTTOM,
        titleText: Text(CS.vSuccess, style: AppTextStyles.body16GreenMedium),
        colorText: AppColors.colorWhite,
      );
    } catch (e) {
      debugPrint('❌ Error deleting download: $e');
      Get.back();

      Get.snackbar(CS.vError, CS.vFailedDeleteNovel, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.colorRed, colorText: AppColors.colorWhite);
    }
  }

  /// Get total storage used
  Future<String> getTotalStorageUsed() async {
    final bytes = await DownloadService.getTotalStorageUsed();
    return formatBytes(bytes);
  }

  /// Format bytes to human readable
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Get download by novel ID
  NovelsDataModel? getDownload(String novelId) {
    try {
      return downloadedNovels.firstWhere((d) => d.id == novelId);
    } catch (e) {
      return null;
    }
  }
}
