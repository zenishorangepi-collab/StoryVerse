import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/book_details_view/book_details_controller.dart';
import 'package:utsav_interview/app/search_view/search_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/common_textfield.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.colorBgGray02,
      body: GetBuilder<SearchScreenController>(
        init: SearchScreenController(),
        builder: (controller) {
          return Column(
            children: [
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(Icons.arrow_back_ios),
                    ).paddingOnly(left: 12),
                  ),

                  Expanded(
                    flex: 10,
                    child: Hero(
                      tag: CS.heroTag,
                      child: Material(
                        color: AppColors.colorTransparent,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: CommonTextFormField(
                            controller: controller.searchController,
                            hint: CS.vSearch,
                            radius: 50,
                            height: 35,
                            fillColor: AppColors.colorBgWhite10,
                            prefix: Image.asset(CS.icSearch, color: AppColors.colorWhite).paddingOnly(top: 7, bottom: 7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ).paddingSymmetric(vertical: 20),

              Expanded(child: _list(controller)),

              SizedBox(height: 50),
            ],
          );
        },
      ),
    );
  }

  Widget _list(SearchScreenController controller) {
    return controller.listNovel.isEmpty
        ? Center(child: Text(CS.vNoNovelFound, style: AppTextStyles.body14WhiteMedium))
        : ListView.separated(
      padding: EdgeInsets.zero,
          itemCount: controller.listNovel.length,
          separatorBuilder: (_, __) => const Divider(color: AppColors.colorGreyDivider, height: 1),
          itemBuilder: (_, index) {
            final book = controller.listNovel[index];

            return GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.bookDetailsScreen, arguments: book);
              },

              child: Container(
                padding: index == 0 ? EdgeInsets.only(left: 20, bottom: 20, right: 20) : EdgeInsets.all(20),
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
                      child:
                          isLocalFile(book.bookCoverUrl)
                              ? Image.file(File(book.bookCoverUrl ?? ""), height: 100, width: 50, fit: BoxFit.contain)
                              : CachedNetworkImage(
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
}
