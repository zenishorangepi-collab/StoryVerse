import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';
import 'package:utsav_interview/app/audio_text_view/widgets/mini_audio_player.dart';
import 'package:utsav_interview/app/auth_options_view/authoptions_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_elevated_button.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';

import '../audio_text_view/audio_text_controller.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🔹 Background Image
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(
                  height: MediaQuery.of(context).size.height / 1.8,
                  width: MediaQuery.of(context).size.width,
                  CS.imgBookCover2, // your image
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

          /// 🔹 Blur Effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: AppColors.colorBgGray02.withOpacity(0.4), // dark overlay
            ),
          ),

          /// 🔹 Optional Gradient (for better text visibility)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,

                colors: [AppColors.colorTransparent, AppColors.colorTransparent, AppColors.colorBgGray04, AppColors.colorBgGray02, AppColors.colorBgGray02],
              ),
            ),
          ),

          /// 🔹 Foreground Content
          SafeArea(
            child: SingleChildScrollView(
              child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      /// Book Cover
                      Center(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(CS.imgBookCover2, height: 260))),

                      const SizedBox(height: 10),

                      Center(child: Text('Princess of Amazon', style: AppTextStyles.heading20WhiteSemiBold)),

                      const SizedBox(height: 4),

                      Center(child: Text('by Alan Mitchell', style: AppTextStyles.body16WhiteBold)),
                      const SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.colorChipBackground),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Column(
                                children: [Text(CS.vLength, style: AppTextStyles.body16GreyMedium), Text("22m", style: AppTextStyles.body16WhiteBold)],
                              ),
                            ),
                            Container(color: AppColors.colorBgWhite10, height: 50, width: 2),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(CS.vPublished, style: AppTextStyles.body16GreyMedium),
                                  Text("Oct 28,2025", style: AppTextStyles.body16WhiteBold),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(CS.vSummary, style: AppTextStyles.body16WhiteBold),
                      const SizedBox(height: 5),
                      Text("er dgdjfbiv djufh bhdifh bidhfibh diojkfhb dhfijkbh dfbhdoubfhi dhfibh dikohfbiodio", style: AppTextStyles.body12GreyRegular),
                      const SizedBox(height: 20),
                      Text(CS.vDetails, style: AppTextStyles.body16WhiteBold),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(child: Text(CS.vLength, style: AppTextStyles.body14GreyRegular)),
                          Expanded(flex: 2, child: Text("2 mins", style: AppTextStyles.body14WhiteBold)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Text(CS.vPublished, style: AppTextStyles.body14GreyRegular)),
                          Expanded(flex: 2, child: Text("Oct 28, 2025", style: AppTextStyles.body14WhiteBold)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Text(CS.vLanguage, style: AppTextStyles.body14GreyRegular)),
                          Expanded(flex: 2, child: Text("English", style: AppTextStyles.body14WhiteBold)),
                        ],
                      ),
                    ],
                  ).screenPadding(),
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
                    ),
                    commonCircleButton(
                      onTap: () {},
                      padding: 8,
                      icon: Icon(Icons.more_horiz, color: AppColors.colorWhite, size: 18),
                      isBackButton: false,
                      iconColor: AppColors.colorWhite,
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
                        bookImage: CS.imgBookCover,
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

      bottomNavigationBar: CommonElevatedButton(
        onTap: () {
          Get.toNamed(AppRoutes.audioTextScreen);
        },
        title: CS.vPlay,
        icon: Icons.play_arrow_rounded,
      ).paddingSymmetric(horizontal: 20).paddingOnly(bottom: 50, top: 20),
    );
  }
}
