import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';
import 'package:utsav_interview/app/audio_text_view/widgets/mini_audio_player.dart';
import 'package:utsav_interview/app/book_details_view/book_details_controller.dart';
import 'package:utsav_interview/app/download_novel/download_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';
import '../../core/common_string.dart';
import 'library_controller.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LibraryController>(
      init: LibraryController(),
      builder: (controller) {
        return Scaffold(
          // backgroundColor: const Color(0xFF1C1C1C),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _header(controller).screenPadding(),
                    const SizedBox(height: 20),
                    _tabs(controller),
                    const SizedBox(height: 20),
                    Expanded(child: _content(controller)),
                  ],
                ),
                StreamBuilder(
                  stream: isBookListening.stream,
                  builder: (context, snap) {
                    if (!isBookListening.value) return SizedBox.fromSize();

                    return StreamBuilder(
                      stream: isPlayAudio.stream,
                      builder: (context, asyncSnapshot) {
                        return StreamBuilder(
                          stream: bookInfo.stream,
                          builder: (context, asyncSnapshot) {
                            return MiniAudioPlayer(
                              bookImage: bookInfo.value.bookCoverUrl ?? "",
                              authorName: bookInfo.value.author?.name ?? "",
                              bookName: bookInfo.value.bookName ?? "",
                              playIcon: isPlayAudio.value ? Icons.pause : Icons.play_arrow_rounded,
                              onReturnFromAudio: () {
                                controller.loadRecents();
                              },
                              onPlayPause: () {
                                Get.find<AudioTextController>().togglePlayPause(isOnlyPlayAudio: true);
                              },
                              onForward10: () {
                                Get.find<AudioTextController>().skipForward();
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// HEADER
  Widget _header(LibraryController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(CS.vLibrary, style: AppTextStyles.heading24WhiteMedium),

        Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.searchScreen, arguments: true);
              },

              child: Hero(
                tag: CS.heroTag,
                child: Container(
                  width: 34,
                  height: 34,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.colorBgWhite10, shape: BoxShape.circle),
                  child: Image.asset(CS.icSearch),
                ),
              ),
            ),
            // PopupMenuButton<SortType>(
            //   offset: Offset(0, 50),
            //   color: AppColors.colorBgGray04,
            //   shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
            //   icon: commonCircleButton(
            //     padding: 8,
            //     icon: Icon(Icons.more_horiz, color: AppColors.colorWhite, size: 18),
            //     isBackButton: false,
            //     iconColor: AppColors.colorWhite,
            //   ),
            //   onSelected: controller.changeSort,
            //   itemBuilder:
            //       (_) => [
            //         PopupMenuItem(enabled: false, height: 30, child: Text(CS.vSortBy, style: AppTextStyles.body14GreyRegular)),
            //         const PopupMenuDivider(height: 1),
            //         PopupMenuItem(
            //           value: SortType.recentlyAdded,
            //           child: Row(
            //             children: [
            //               Expanded(flex: 5, child: Text(CS.vRecentlyAdded, style: AppTextStyles.body14WhiteMedium)),
            //               if (controller.selectedSort == SortType.recentlyAdded) Expanded(child: Icon(Icons.check, color: AppColors.colorWhite, size: 18)),
            //             ],
            //           ),
            //         ),
            //         const PopupMenuDivider(height: 1),
            //         PopupMenuItem(
            //           value: SortType.recentlyListened,
            //           child: Row(
            //             children: [
            //               Expanded(flex: 5, child: Text(CS.vRecentlyListened, style: AppTextStyles.body14WhiteMedium)),
            //               if (controller.selectedSort == SortType.recentlyListened) Expanded(child: Icon(Icons.check, color: AppColors.colorWhite, size: 18)),
            //             ],
            //           ),
            //         ),
            //         const PopupMenuDivider(height: 1),
            //         PopupMenuItem(
            //           value: SortType.progress,
            //           child: Row(
            //             children: [
            //               Expanded(flex: 5, child: Text(CS.vProgress, style: AppTextStyles.body14WhiteMedium)),
            //               if (controller.selectedSort == SortType.progress)
            //                 Expanded(
            //                   flex: 4,
            //                   child: Align(
            //                     alignment: Alignment.centerRight,
            //                     child: Icon(Icons.check, color: AppColors.colorWhite, size: 18).paddingOnly(right: 10),
            //                   ),
            //                 ),
            //             ],
            //           ),
            //         ),
            //       ],
            // ),
          ],
        ),
      ],
    );
  }

  /// TABS
  Widget _tabs(LibraryController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _tab(CS.vSaved, LibraryTab.saved, controller).paddingOnly(left: 20),
          _tab(CS.vCollections, LibraryTab.collections, controller),
          _tab(CS.vArchive, LibraryTab.archive, controller),
        ],
      ),
    );
  }

  Widget _tab(String title, LibraryTab tab, LibraryController controller) {
    final isSelected = controller.selectedTab == tab;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => controller.changeTab(tab),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.grey.shade800, borderRadius: BorderRadius.circular(20)),
          child: Row(
            spacing: 5,
            children: [
              if (title != CS.vSaved)
                Image.asset(
                  title == CS.vCollections ? CS.icCollections : CS.icArchive,
                  height: 20,
                  color: isSelected ? AppColors.colorBlack : AppColors.colorWhite,
                ),
              Text(title, style: isSelected ? AppTextStyles.body14BlackMedium : AppTextStyles.body14WhiteBold),
            ],
          ),
        ),
      ),
    );
  }

  /// CONTENT
  Widget _content(LibraryController controller) {
    switch (controller.selectedTab) {
      case LibraryTab.collections:
        return _collectionsView();
      case LibraryTab.archive:
        return _archived();
      default:
        return _savedView();
    }
  }

  /// SAVED VIEW
  Widget _savedView() {
    return GetBuilder<LibraryController>(
      init: LibraryController(),
      builder: (controller) {
        return controller.savedRecents.isEmpty
            ? Center(child: Text(CS.vNoSavedFound, style: AppTextStyles.body14WhiteMedium))
            : ListView.builder(
              itemCount: controller.savedRecents.length,
              itemBuilder: (context, index) {
                final book = controller.savedRecents[index];

                return AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Slidable(
                    key: ValueKey(book.id),

                    /// LEFT ACTIONS
                    // startActionPane: ActionPane(
                    //   motion: const BehindMotion(),
                    //   extentRatio: 0.50,
                    //   children: [
                    //     commonActionButton(color: AppColors.colorTeal, icon: Icons.remove_circle_outline, label: CS.vRemoveFromQueue, onTap: () {}),
                    //   ],
                    // ),

                    /// RIGHT ACTIONS
                    endActionPane: ActionPane(
                      motion: const BehindMotion(),
                      extentRatio: 0.5,
                      children: [
                        // commonActionButton(color: AppColors.colorDarkPurple, icon: Icons.mark_email_unread, label: CS.vMarkAsUnread, onTap: () {}),
                        commonActionButton(
                          color: AppColors.colorBlue,
                          icon: Icons.file_download_outlined,
                          label: CS.vDownload,
                          onTap: () async {
                            final DownloadController downloadController =
                                Get.isRegistered<DownloadController>() ? Get.find<DownloadController>() : Get.put(DownloadController());

                            await Future.delayed(const Duration(milliseconds: 250));

                            // Start download
                            await downloadController.downloadNovel(book);
                          },
                        ),

                        commonActionButton(
                          color: AppColors.colorBgWhite10,
                          icon: Icons.archive,
                          label: CS.vArchive,
                          onTap: () async {
                            controller.archiveBook(book.id ?? "");
                          },
                        ),
                      ],
                    ),

                    /// MAIN CARD
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.bookDetailsScreen, arguments: book);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: const Border(bottom: BorderSide(color: AppColors.colorGreyDivider, width: 2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(color: AppColors.colorChipBackground, borderRadius: BorderRadius.circular(5)),
                              child:
                                  isLocalFile(book.bookCoverUrl)
                                      ? Image.file(File(book.bookCoverUrl ?? ""), height: 80, width: 50, fit: BoxFit.cover)
                                      : CachedNetworkImage(
                                        height: 80,
                                        width: 50,
                                        fit: BoxFit.contain,
                                        imageUrl: book.bookCoverUrl ?? "",
                                        errorWidget: (_, __, ___) => Image.asset(CS.imgBookCover2, height: 80),
                                      ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(book.bookName ?? "", style: AppTextStyles.body14WhiteBold),
                                  Text(book.author?.name ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body14GreySemiBold),
                                  const SizedBox(height: 10),
                                  Text(book.summary ?? "", maxLines: 3, overflow: TextOverflow.ellipsis, style: AppTextStyles.body14GreySemiBold),
                                  const SizedBox(height: 10),
                                  Text(secondsToMinSec(book.totalAudioLength ?? 0.0), style: AppTextStyles.body14GreySemiBold),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).paddingOnly(bottom: isBookListening.value && index == (controller.archivedRecents.length - 1) ? 70 : 0);
              },
            );
      },
    );
  }

  Widget _archived() {
    return GetBuilder<LibraryController>(
      init: LibraryController(),
      builder: (controller) {
        return controller.archivedRecents.isEmpty
            ? Center(child: Text(CS.vNoArchiveFound, style: AppTextStyles.body14WhiteMedium))
            : ListView.builder(
              itemCount: controller.archivedRecents.length,
              itemBuilder: (context, index) {
                final book = controller.archivedRecents[index];

                return AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Slidable(
                    key: ValueKey(book.id), // ✅ UNIQUE KEY
                    /// RIGHT SIDE ACTIONS ➡➡➡➡➡➡➡
                    endActionPane: ActionPane(
                      motion: const BehindMotion(),
                      extentRatio: 0.3,
                      dismissible: DismissiblePane(
                        onDismissed: () {
                          controller.unArchiveBook(book.id ?? "");
                        },
                      ),
                      children: [
                        commonActionButton(
                          color: AppColors.colorBgWhite10,
                          icon: Icons.unarchive, // better UX icon
                          label: CS.vRemoveFromArchive,
                          onTap: () async {
                            final slidable = Slidable.of(context);

                            // 1️⃣ Close action pane
                            await slidable?.close();

                            // 2️⃣ Small delay for smooth animation
                            await Future.delayed(const Duration(milliseconds: 180));

                            // 3️⃣ Unarchive + remove from list
                            controller.unArchiveBook(book.id ?? "");
                          },
                        ),
                      ],
                    ),

                    /// MAIN CARD
                    child: GestureDetector(
                      onTap: () async {
                        await Get.toNamed(AppRoutes.bookDetailsScreen, arguments: book);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: const Border(bottom: BorderSide(color: AppColors.colorGreyDivider, width: 2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(color: AppColors.colorChipBackground, borderRadius: BorderRadius.circular(5)),
                              child:
                                  isLocalFile(book.bookCoverUrl)
                                      ? Image.file(File(book.bookCoverUrl ?? ""), height: 80, width: 50, fit: BoxFit.cover)
                                      : CachedNetworkImage(
                                        height: 80,
                                        width: 50,
                                        fit: BoxFit.cover,
                                        imageUrl: book.bookCoverUrl ?? "",
                                        errorWidget: (_, __, ___) => Image.asset(CS.imgBookCover2, height: 80),
                                      ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(book.bookName ?? "", style: AppTextStyles.body14WhiteBold),
                                  Text(book.author?.name ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body14GreySemiBold),
                                  const SizedBox(height: 10),
                                  Text(book.summary ?? "", maxLines: 3, overflow: TextOverflow.ellipsis, style: AppTextStyles.body14GreySemiBold),
                                  const SizedBox(height: 10),
                                  Text(secondsToMinSec(book.totalAudioLength ?? 0.0), style: AppTextStyles.body14GreySemiBold),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).paddingOnly(bottom: isBookListening.value && index == (controller.archivedRecents.length - 1) ? 70 : 0);
              },
            );
      },
    );
  }

  /// COLLECTIONS VIEW
  Widget _collectionsView() {
    return GetBuilder<LibraryController>(
      init: LibraryController(),
      builder: (controller) {
        return ListView(
          children: [
            Text(CS.vYourCollections, style: AppTextStyles.body14GreyBold).paddingOnly(bottom: 5).screenPadding(),

            commonListTile(
              onTap: () {
                Get.toNamed(AppRoutes.createCollectionScreen);
              },
              imageHeight: 25,
              title: CS.vCreateACollection,
              icon: Icons.add,
              style: AppTextStyles.body16WhiteBold,
            ),
            Divider(color: AppColors.colorGreyDivider),

            if (controller.listCollection.isNotEmpty)
              ...List.generate(controller.listCollection.length, (index) {
                return Column(
                  children: [
                    commonListTile(
                      onTap: () {
                        Get.toNamed(AppRoutes.collectionScreen, arguments: controller.listCollection[index]);
                      },
                      imageHeight: 25,
                      title: controller.listCollection[index].name,
                      icon: icon(controller.listCollection[index].iconType),
                      style: AppTextStyles.body16WhiteBold,
                    ),
                    Divider(color: AppColors.colorGreyDivider),
                  ],
                );
              }),
            commonListTile(
              title: CS.vDownloaded,
              icon: Icons.download,
              trailing: Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey),
              style: AppTextStyles.body16WhiteBold,
              onTap: () {
                Get.toNamed(AppRoutes.downloadNovel);
              },
            ),
            Divider(color: AppColors.colorGreyDivider).paddingOnly(bottom: isBookListening.value ? 70 : 0),
            // Text(CS.vByType, style: AppTextStyles.body14GreyBold).paddingOnly(bottom: 5, top: 15),
            // commonListTile(
            //   title: CS.vBooks,
            //   icon: Icons.book,
            //   trailing: Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey),
            //   style: AppTextStyles.body16WhiteBold,
            // ),
            //
            // Divider(color: AppColors.colorGreyDivider),
            // commonListTile(
            //   title: CS.vGenFm,
            //   icon: Icons.auto_awesome,
            //   trailing: Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey),
            //   style: AppTextStyles.body16WhiteBold,
            // ),
            //
            // Divider(color: AppColors.colorGreyDivider),
            // commonListTile(
            //   title: CS.vImports,
            //   icon: Icons.grid_view,
            //   trailing: Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey),
            //   style: AppTextStyles.body16WhiteBold,
            // ),
            //
            // Divider(color: AppColors.colorGreyDivider),
            // commonListTile(
            //   title: CS.vLinks,
            //   icon: Icons.link,
            //   trailing: Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey),
            //   style: AppTextStyles.body16WhiteBold,
            // ),
            // Divider(color: AppColors.colorGreyDivider),
            // commonListTile(
            //   title: CS.vText,
            //   icon: Icons.text_fields,
            //   trailing: Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey),
            //   style: AppTextStyles.body16WhiteBold,
            // ),
            // Divider(color: AppColors.colorGreyDivider),
          ],
        );
      },
    );
  }
}

void showDownloadProgressDialog() {
  Get.dialog(
    GetBuilder<DownloadController>(
      builder: (controller) {
        return AlertDialog(
          backgroundColor: AppColors.colorBgGray02,
          title: Text('Downloading...', style: AppTextStyles.body16WhiteBold),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: controller.downloadProgress,
                backgroundColor: AppColors.colorBgWhite10,
                valueColor: AlwaysStoppedAnimation(AppColors.colorWhite),
              ),
              SizedBox(height: 16),
              Text('${(controller.downloadProgress * 100).toStringAsFixed(0)}%', style: AppTextStyles.body14WhiteMedium),
            ],
          ),
        );
      },
    ),
    barrierDismissible: false,
  );
}
