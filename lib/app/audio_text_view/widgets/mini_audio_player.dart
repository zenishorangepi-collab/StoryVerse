import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class MiniAudioPlayer extends StatelessWidget {
  final String bookName;
  final String authorName;
  final String bookImage;
  final VoidCallback? onPlayPause;
  final VoidCallback? onForward10;
  IconData? playIcon;
  final VoidCallback? onReturnFromAudio;

  MiniAudioPlayer({
    super.key,
    required this.bookName,
    required this.authorName,
    required this.bookImage,
    this.onPlayPause,
    this.playIcon = Icons.play_arrow_rounded,
    this.onForward10,
    this.onReturnFromAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 10,
      child: GestureDetector(
        onTap: () async {
          final result = await Get.toNamed(AppRoutes.audioTextScreen, arguments: {"isInitCall": false});
          if (result != null) {
            onReturnFromAudio?.call();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: AppColors.colorDialogHeader, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 5),
              isLocalFile(bookImage)
                  ? Image.file(File(bookImage), width: 50, height: 35, fit: BoxFit.contain)
                  : CachedNetworkImage(
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    imageUrl: bookImage,
                    errorWidget: (context, error, stackTrace) {
                      return commonBookIcon(size: 40);
                    },
                  ),

              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(authorName, style: AppTextStyles.body14GreyRegular, maxLines: 1).paddingOnly(bottom: 2),
                    Text(bookName, maxLines: 1, style: AppTextStyles.body14WhiteMedium, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),

              IconButton(onPressed: onPlayPause, icon: Icon(playIcon, size: 40, color: AppColors.colorWhite)),
              IconButton(onPressed: onForward10, icon: const Icon(Icons.forward_10_rounded, size: 30, color: AppColors.colorWhite)),
            ],
          ),
        ),
      ),
    );
  }
}
