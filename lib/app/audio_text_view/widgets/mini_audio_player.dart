import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class MiniAudioPlayer extends StatelessWidget {
  final String bookName;
  final String authorName;
  final String bookImage;
  final VoidCallback? onPlayPause;
  final VoidCallback? onForward10;
  IconData? playIcon;

  MiniAudioPlayer({
    super.key,
    required this.bookName,
    required this.authorName,
    required this.bookImage,
    this.onPlayPause,
    this.playIcon = Icons.play_arrow_rounded,
    this.onForward10,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 10,
      child: GestureDetector(
        onTap: () {
          Get.toNamed(AppRoutes.audioTextScreen, arguments: true);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: AppColors.colorDialogHeader, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 5),
              Image.asset(bookImage, width: 50, height: 35),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(authorName, style: AppTextStyles.body14GreyRegular, maxLines: 1),
                  Text(bookName, maxLines: 1, style: AppTextStyles.body16WhiteMedium),
                ],
              ),
              const Spacer(),
              IconButton(onPressed: onPlayPause, icon: Icon(playIcon, size: 40, color: AppColors.colorWhite)),
              IconButton(onPressed: onForward10, icon: const Icon(Icons.forward_10_rounded, size: 30, color: AppColors.colorWhite)),
            ],
          ),
        ),
      ),
    );
  }
}
