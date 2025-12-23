import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';
import 'package:utsav_interview/app/audio_text_view/widgets/mini_audio_player.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_style.dart';
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
                    const SizedBox(height: 16),
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
                              bookImage: bookInfo.value.bookImage,
                              authorName: bookInfo.value.authorName,
                              bookName: bookInfo.value.bookName,
                              playIcon: isPlayAudio.value ? Icons.pause : Icons.play_arrow_rounded,
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
            commonCircleButton(
              onTap: () {},
              padding: 8,
              iconSize: 18,
              iconPath: CS.icSearch,
              // icon: Icon(Icons.more_horiz, color: AppColors.colorWhite, size: 18),
              isBackButton: false,
              iconColor: AppColors.colorWhite,
            ),
            PopupMenuButton<SortType>(
              offset: Offset(0, 50),
              color: AppColors.colorBgGray04,
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
              icon: commonCircleButton(
                padding: 8,
                icon: Icon(Icons.more_horiz, color: AppColors.colorWhite, size: 18),
                isBackButton: false,
                iconColor: AppColors.colorWhite,
              ),
              onSelected: controller.changeSort,
              itemBuilder:
                  (_) => [
                    PopupMenuItem(enabled: false, height: 30, child: Text(CS.vSortBy, style: AppTextStyles.body14GreyRegular)),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem(
                      value: SortType.recentlyAdded,
                      child: Row(
                        children: [
                          Expanded(flex: 5, child: Text(CS.vRecentlyAdded, style: AppTextStyles.body14WhiteMedium)),
                          if (controller.selectedSort == SortType.recentlyAdded) Expanded(child: Icon(Icons.check, color: AppColors.colorWhite, size: 18)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem(
                      value: SortType.recentlyListened,
                      child: Row(
                        children: [
                          Expanded(flex: 5, child: Text(CS.vRecentlyListened, style: AppTextStyles.body14WhiteMedium)),
                          if (controller.selectedSort == SortType.recentlyListened) Expanded(child: Icon(Icons.check, color: AppColors.colorWhite, size: 18)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem(
                      value: SortType.progress,
                      child: Row(
                        children: [
                          Expanded(flex: 5, child: Text(CS.vProgress, style: AppTextStyles.body14WhiteMedium)),
                          if (controller.selectedSort == SortType.progress)
                            Expanded(
                              flex: 4,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.check, color: AppColors.colorWhite, size: 18).paddingOnly(right: 10),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
            ),
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
        return _savedView();
      default:
        return _savedView();
    }
  }

  /// SAVED VIEW
  Widget _savedView() {
    return ListView(
      children: [
        Slidable(
          key: const ValueKey(0),

          /// LEFT SIDE ACTIONS ⬅⬅⬅⬅⬅⬅⬅
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.50,
            children: [
              commonActionButton(color: AppColors.colorBlue, icon: Icons.file_download_outlined, label: CS.vDownload, onTap: () {}),
              commonActionButton(color: AppColors.colorTeal, icon: Icons.remove_circle_outline, label: CS.vRemoveFromQueue, onTap: () {}),
            ],
          ),

          /// RIGHT SIDE ACTIONS ➡➡➡➡➡➡➡
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.75,
            children: [
              commonActionButton(color: AppColors.colorDarkGreen, icon: Icons.add, label: CS.vAddToCollection, onTap: () {}),

              commonActionButton(color: AppColors.colorDarkPurple, icon: Icons.mark_email_unread, label: CS.vMarkAsUnread, onTap: () {}),

              commonActionButton(color: AppColors.colorBgWhite10, icon: Icons.archive, label: CS.vArchive, onTap: () {}),
            ],
          ),

          /// MAIN CARD (unchanged)
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: const Border(bottom: BorderSide(color: AppColors.colorGreyDivider, width: 2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(color: AppColors.colorChipBackground, borderRadius: BorderRadius.circular(5)),
                  child: Image.asset(CS.imgBookCover, height: 80),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(CS.vBookTitle, style: AppTextStyles.body14WhiteBold),

                      Text("${CS.vAuthorName}\n${CS.vDuration}", maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body14GreySemiBold),

                      const SizedBox(height: 10),

                      Text(
                        "Deep in the Amazon, Princess seraphine defines her queen and embarks on a quest to discover dshu dfkj dkf",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body14GreySemiBold,
                      ),

                      const SizedBox(height: 10),

                      Text("1% 20 mins left", maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body14GreySemiBold),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  commonActionButton({Color? color, IconData? icon, String? label, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(color: color),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.colorWhite),
              const SizedBox(height: 5),
              Text(label ?? "", textAlign: TextAlign.center, style: AppTextStyles.body14WhiteMedium),
            ],
          ),
        ),
      ),
    );
  }

  /// COLLECTIONS VIEW
  Widget _collectionsView() {
    return ListView(
      children: [
        Text(CS.vYourCollections, style: AppTextStyles.body14GreyBold).paddingOnly(bottom: 5),

        // commonListTile(imageHeight: 30, title: CS.vCreateCollection, icon: Icons.add, style: AppTextStyles.body16WhiteBold),
        // Divider(color: AppColors.colorGreyDivider),
        commonListTile(
          title: CS.vDownloaded,
          icon: Icons.download,
          trailing: Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey),
          style: AppTextStyles.body16WhiteBold,
        ),
        Divider(color: AppColors.colorGreyDivider),
        Text(CS.vByType, style: AppTextStyles.body14GreyBold).paddingOnly(bottom: 5, top: 15),
        commonListTile(
          title: CS.vBooks,
          icon: Icons.book,
          trailing: Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey),
          style: AppTextStyles.body16WhiteBold,
        ),

        Divider(color: AppColors.colorGreyDivider),
        commonListTile(
          title: CS.vGenFm,
          icon: Icons.auto_awesome,
          trailing: Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey),
          style: AppTextStyles.body16WhiteBold,
        ),

        Divider(color: AppColors.colorGreyDivider),
        commonListTile(
          title: CS.vImports,
          icon: Icons.grid_view,
          trailing: Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey),
          style: AppTextStyles.body16WhiteBold,
        ),

        Divider(color: AppColors.colorGreyDivider),
        commonListTile(
          title: CS.vLinks,
          icon: Icons.link,
          trailing: Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey),
          style: AppTextStyles.body16WhiteBold,
        ),
        Divider(color: AppColors.colorGreyDivider),
        commonListTile(
          title: CS.vText,
          icon: Icons.text_fields,
          trailing: Icon(Icons.keyboard_arrow_right, color: AppColors.colorGrey),
          style: AppTextStyles.body16WhiteBold,
        ),
        Divider(color: AppColors.colorGreyDivider),
      ],
    ).screenPadding();
  }
}
