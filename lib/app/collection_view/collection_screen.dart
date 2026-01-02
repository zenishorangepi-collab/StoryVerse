import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/book_details_view/book_details_controller.dart';
import 'package:utsav_interview/app/collection_view/collection_controller.dart';
import 'package:utsav_interview/app/download_novel/download_controller.dart';
import 'package:utsav_interview/app/library_view/library_screen.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CollectionController>(
      init: CollectionController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFF2B2B2B),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 40,
            leading: commonCircleButton(
              onTap: () {
                Get.back();
              },
              padding: 8,
              icon: Icon(Icons.arrow_back_ios, color: AppColors.colorWhite, size: 15).paddingOnly(left: 2),
              isBackButton: false,

              iconColor: AppColors.colorWhite,
              bgColor: AppColors.colorChipBackground,
            ).paddingOnly(left: 10),

            actions: [
              commonCircleButton(
                padding: 4,
                onTap: () async {
                  final result = await Get.toNamed(AppRoutes.addToCollection, arguments: {"collectionId": controller.collection?.id});
                  if (result != null) {
                    controller.getNovelData();
                  }
                },
                icon: Icon(Icons.add, color: AppColors.colorBlack, size: 22),
                isBackButton: false,
                bgColor: AppColors.colorWhite,
                iconColor: AppColors.colorWhite,
              ),
              SizedBox(width: 5),

              PopupMenuButton<int>(
                color: AppColors.colorBgGray04,

                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
                icon: commonCircleButton(
                  padding: 8,
                  icon: Icon(Icons.more_vert, color: AppColors.colorWhite, size: 18),
                  isBackButton: false,
                  iconColor: AppColors.colorWhite,
                ),

                itemBuilder: (_) => [_menuItem(0, CS.vEditCollection, Icons.edit), _menuItem(1, CS.vDelete, Icons.delete)],
                onSelected: (value) {
                  if (value == 0) {
                  } else {
                    showDeleteDialog(
                      context,
                      onConfirm: () {
                        Get.back();
                        controller.deleteCollection(controller.collection?.id ?? "");
                      },
                    );
                  }
                },
              ).paddingOnly(right: 10),
            ],
          ),
          body: Center(
            child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(controller.collection?.name ?? "", style: AppTextStyles.heading24WhiteMedium),
                    if (controller.listNovelData.isEmpty) const SizedBox(height: 80),
                    controller.listNovelData.isEmpty
                        ? Center(
                          child: Column(
                            children: [
                              _stackedBooks(),
                              const SizedBox(height: 32),
                              Text(
                                CS.vEmptyCollectionMessage,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                              const SizedBox(height: 32),
                              CommonElevatedButton(
                                title: CS.vAddContent,
                                onTap: () async {
                                  final result = await Get.toNamed(AppRoutes.addToCollection, arguments: {"collectionId": controller.collection?.id});
                                  if (result != null) {
                                    controller.getNovelData();
                                  }
                                },
                              ).paddingSymmetric(horizontal: 60),
                            ],
                          ),
                        )
                        : Expanded(
                          child: ListView.separated(
                            itemCount: controller.listNovelData.length,
                            separatorBuilder: (_, __) => const Divider(color: Colors.grey, height: 1),
                            itemBuilder: (_, index) {
                              final book = controller.listNovelData[index];

                              return AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: Slidable(
                                  key: ValueKey(book.id), // ✅ UNIQUE KEY
                                  /// RIGHT ACTIONS
                                  endActionPane: ActionPane(
                                    motion: const BehindMotion(),
                                    extentRatio: 0.5,
                                    children: [
                                      commonActionButton(
                                        color: AppColors.colorBlue,
                                        icon: Icons.file_download_outlined,
                                        label: CS.vDownload,
                                        onTap: () async {
                                          final DownloadController downloadController =
                                              Get.isRegistered<DownloadController>() ? Get.find<DownloadController>() : Get.put(DownloadController());

                                          final slidable = Slidable.of(context);
                                          await slidable?.close();
                                          await Future.delayed(const Duration(milliseconds: 250));

                                          // Start download
                                          await downloadController.downloadNovel(book);
                                        },
                                      ),
                                      commonActionButton(
                                        color: AppColors.colorRed,
                                        icon: Icons.delete_outline,
                                        label: CS.vRemove,
                                        onTap: () async {
                                          controller.removeNovelFromCollection(collectionId: controller.collection?.id ?? "", novelId: book.id ?? "");
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
                                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: const Border(bottom: BorderSide(color: AppColors.colorGreyDivider, width: 1)),
                                      ),
                                      child: Row(
                                        spacing: 15,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                            decoration: BoxDecoration(color: AppColors.colorChipBackground, borderRadius: BorderRadius.circular(5)),
                                            child: CachedNetworkImage(
                                              height: 100,
                                              width: 50,
                                              fit: BoxFit.contain,
                                              imageUrl: book.bookCoverUrl ?? "",
                                              errorWidget: (_, __, ___) => Image.asset(CS.imgBookCover2, height: 80),
                                            ),
                                          ),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(book.bookName ?? "", style: AppTextStyles.body14WhiteBold),
                                                Text(
                                                  book.author?.name ?? "",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppTextStyles.body14GreySemiBold,
                                                ),
                                                const SizedBox(height: 10),
                                                Text(book.summary ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.body14GreySemiBold),
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
                              );
                            },
                          ),
                        ),
                  ],
                ).screenPadding(),
          ),
        );
      },
    );
  }

  PopupMenuItem<int> _menuItem(int value, String title, IconData icon) {
    return PopupMenuItem(value: value, child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(title)]));
  }

  /// Decorative stacked books (center image)
  Widget _stackedBooks() {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Book 1
          Transform.rotate(
            angle: -0.2,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.colorTealDark,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
              ),
            ),
          ),
          // Book 2
          Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.colorRed,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
            ),
          ),
          // Book 3
          Transform.rotate(
            angle: 0.2,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.colorBrown,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showDeleteDialog(BuildContext context, {required VoidCallback onConfirm}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          // insetPadding: EdgeInsets.zero,
          backgroundColor: AppColors.colorBgGray02,
          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(CS.vConfirmDeletion, style: AppTextStyles.body16WhiteBold),
          content: Text(CS.vYouWillNoLonger, style: AppTextStyles.body16WhiteRegular),
          actionsAlignment: MainAxisAlignment.end,
          // right side buttons
          actions: [
            TextButton(
              style: ButtonStyle(overlayColor: WidgetStatePropertyAll(AppColors.colorTransparent)),
              onPressed: () => Navigator.pop(context),
              child: Text(CS.vDismiss, style: AppTextStyles.body16WhiteBold),
            ),
            TextButton(
              style: ButtonStyle(overlayColor: WidgetStatePropertyAll(AppColors.colorTransparent)),
              onPressed: () {
                onConfirm();
              },
              child: Text(CS.vConfirm, style: AppTextStyles.body16RedBold),
            ),
          ],
        );
      },
    );
  }
}
