import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:utsav_interview/app/add_collection_view/add_collection_controller.dart';
import 'package:utsav_interview/app/book_details_view/book_details_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/common_textfield.dart';

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
            leading: const BackButton(),
            title: Text(CS.vAddToCollection),
            centerTitle: true,
          ),

          body: Column(
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

class _Book {
  final String id;
  final String title;
  final String author;
  final String progress;

  _Book(this.id, this.title, this.author, this.progress);
}
