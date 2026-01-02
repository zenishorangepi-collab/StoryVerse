import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';
import 'package:utsav_interview/app/audio_text_view/widgets/mini_audio_player.dart';
import 'package:utsav_interview/app/book_details_view/book_details_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookDetailsController>(
      init: BookDetailsController(),
      builder: (controller) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              /// 🔹 Foreground Content
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(height: 60),

                      /// Book Cover
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          /// 🔹 Background Image
                          isLocalFile(controller.novelData.bookCoverUrl)
                              ? Image.file(
                                File(controller.novelData.bookCoverUrl ?? ""),
                                height: MediaQuery.of(context).size.height / 2.5,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              )
                              : CachedNetworkImage(
                                height: MediaQuery.of(context).size.height / 2.5,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                                imageUrl: controller.novelData.bookCoverUrl ?? "", // your image
                              ),

                          /// 🔹 Blur Effect
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              color: AppColors.colorBgGray02, // dark overlay
                            ),
                          ),

                          Positioned(
                            bottom: 100,
                            right: 0,
                            left: 0,

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  isLocalFile(controller.novelData.bookCoverUrl)
                                      ? Image.file(File(controller.novelData.bookCoverUrl ?? ""), height: 150)
                                      : CachedNetworkImage(imageUrl: controller.novelData.bookCoverUrl ?? "", height: 150),
                            ),
                          ),

                          Positioned(bottom: 60, child: Text(controller.novelData.bookName ?? "", style: AppTextStyles.heading18WhiteSemiBold).screenPadding()),

                          Positioned(
                            bottom: 40,
                            child: Text("by ${controller.novelData.author?.name}", style: AppTextStyles.body14WhiteMedium).screenPadding(),
                          ),
                        ],
                      ),

                      // const SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.colorChipBackground),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Column(
                                spacing: 5,
                                children: [
                                  Text(CS.vLength, style: AppTextStyles.body14GreyBold),
                                  Text(controller.audioDuration, style: AppTextStyles.body14WhiteBold),
                                ],
                              ),
                            ),
                            Container(color: AppColors.colorBgWhite10, height: 50, width: 2),
                            Expanded(
                              child: Column(
                                spacing: 5,
                                children: [
                                  Text(CS.vPublished, style: AppTextStyles.body14GreyBold),
                                  Text(formatDate(controller.novelData.publishedDate ?? ""), style: AppTextStyles.body14WhiteBold),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).screenPadding(),
                      const SizedBox(height: 20),
                      Text(CS.vSummary, style: AppTextStyles.body16WhiteBold).screenPadding(),
                      const SizedBox(height: 5),
                      Text(controller.novelData.summary ?? "", style: AppTextStyles.body14GreyRegular).screenPadding(),
                      const SizedBox(height: 10),
                      Text(CS.vDetails, style: AppTextStyles.body16WhiteBold).screenPadding(),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Text(CS.vLength, style: AppTextStyles.body14GreyRegular)),
                          Expanded(flex: 2, child: Text(controller.audioDuration, style: AppTextStyles.body14WhiteMedium)),
                        ],
                      ).screenPadding(),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(child: Text(CS.vPublished, style: AppTextStyles.body14GreyRegular)),
                          Expanded(flex: 2, child: Text(formatDate(controller.novelData.publishedDate ?? ""), style: AppTextStyles.body14WhiteMedium)),
                        ],
                      ).screenPadding(),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(child: Text(CS.vLanguage, style: AppTextStyles.body14GreyRegular)),
                          Expanded(flex: 2, child: Text(controller.novelData.language?.name ?? "", style: AppTextStyles.body14WhiteMedium)),
                        ],
                      ).screenPadding(),
                    ],
                  ).paddingOnly(bottom: isBookListening.value ? 100 : 0),
                ),
              ),

              Container(
                height: 50,
                margin: EdgeInsets.only(top: 50),
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    commonCircleButton(
                      onTap: () {
                        Get.back();
                      },
                      padding: 8,
                      icon: Icon(Icons.arrow_back_ios, color: AppColors.colorWhite, size: 18).paddingOnly(left: 6),
                      isBackButton: false,

                      iconColor: AppColors.colorWhite,
                      bgColor: AppColors.colorChipBackground,
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        commonCircleButton(
                          onTap: () {},
                          padding: 8,
                          icon: Icon(Icons.share, color: AppColors.colorWhite, size: 18),
                          isBackButton: false,
                          iconColor: AppColors.colorWhite,
                          bgColor: AppColors.colorChipBackground,
                        ),
                        commonCircleButton(
                          onTap: () {},
                          padding: 8,
                          icon: Icon(Icons.more_horiz, color: AppColors.colorWhite, size: 18),
                          isBackButton: false,
                          iconColor: AppColors.colorWhite,
                          bgColor: AppColors.colorChipBackground,
                        ),
                      ],
                    ),
                  ],
                ),
              ).screenPadding(),

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

          bottomNavigationBar: CommonElevatedButton(
            onTap: () {
              if (bookInfo.value.id != controller.novelData.id && isAudioInitCount.value != 0) {
                isAudioInitCount.value = 0;
                Get.find<AudioTextController>().pause();
              }
              Get.toNamed(AppRoutes.audioTextScreen, arguments: {"novelData": controller.novelData, "isInitCall": true});
            },
            title: CS.vPlay,
            icon: Icons.play_arrow_rounded,
          ).paddingSymmetric(horizontal: 20).paddingOnly(bottom: 50, top: 20),
        );
      },
    );
  }
}
