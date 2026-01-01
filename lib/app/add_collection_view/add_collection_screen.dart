import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/add_collection_view/add_collection_controller.dart';
import 'package:utsav_interview/app/book_details_view/book_details_controller.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
import 'package:utsav_interview/app/library_view/library_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/common_textfield.dart';
import 'package:utsav_interview/core/pref.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class AddToCollectionScreen extends StatelessWidget {
  const AddToCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddToCollectionController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFF2B2B2B),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2B2B2B),
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
            title: Text(CS.vAddToCollection),
          ),

          body:
              (controller.novelData != null)
                  ? Column(
                    children: [
                      commonListTile(
                        onTap: () {
                          Get.toNamed(AppRoutes.createCollectionScreen, arguments: true);
                        },
                        imageHeight: 30,
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
                                onTap: () async {
                                  await controller.addNovelToCollection(
                                    collectionId: controller.listCollection[index].id,
                                    novelId: controller.novelData?.id ?? "",
                                    novel: controller.novelData ?? NovelsDataModel(),
                                  );
                                  Get.back();
                                },
                                imageHeight: 30,
                                title: controller.listCollection[index].name,
                                icon: icon(controller.listCollection[index].iconType),
                                style: AppTextStyles.body16WhiteBold,
                              ),
                              Divider(color: AppColors.colorGreyDivider),
                            ],
                          );
                        }),
                    ],
                  )
                  : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CommonTextFormField(
                          controller: controller.searchController,
                          hint: CS.vSearch,
                          prefix: Image.asset(CS.icSearch, height: 5, width: 5, color: AppColors.colorGrey).paddingAll(12),
                        ),
                      ),
                      Expanded(child: _list(controller)),
                      _bottomButton(controller),
                      SizedBox(height: 50),
                    ],
                  ),
        );
      },
    );
  }

  Widget _list(AddToCollectionController controller) {
    return controller.isDataLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.colorWhite))
        : controller.listNovelData.isEmpty
        ? Center(child: Text(CS.vNoNovelFound, style: AppTextStyles.body14WhiteMedium))
        : ListView.separated(
          itemCount: controller.listNovelData.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.grey, height: 1),
          itemBuilder: (_, index) {
            final book = controller.listNovelData[index];
            final selected = controller.selectedIds.contains(book.id);

            return GestureDetector(
              onTap: () {
                controller.selectedIds.contains(book.id) ? controller.selectedIds.remove(book.id) : controller.selectedIds.add(book.id ?? "");
                if (controller.selectedIds.contains(book.id)) {
                  controller.listSelectedNovel.add(book);
                } else {
                  controller.listSelectedNovel.removeWhere((element) => element.id == book.id);
                }

                controller.update();
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: const Border(bottom: BorderSide(color: AppColors.colorGreyDivider, width: 1)),
                ),
                child: Row(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    selected ? Icon(Icons.check_circle_rounded) : Icon(Icons.circle_outlined),
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
                          Text(book.author?.name ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body14GreySemiBold),
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
            );
          },
        );
  }

  Widget _bottomButton(AddToCollectionController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: CommonElevatedButton(
          onTap:
              controller.isButtonEnabled
                  ? () async {
                    AppPrefs.remove(CS.keyCollectionBooks);
                    for (var element in controller.listSelectedNovel) {
                      await controller.saveNovelToCollection(collectionId: controller.collectionId, novel: element);
                    }
                    Get.back(result: true);
                  }
                  : () {},
          backgroundColor: controller.isButtonEnabled ? AppColors.colorWhite : AppColors.colorGrey,
          title: CS.vSaveToCollection,
        ),
      ),
    );
  }
}
