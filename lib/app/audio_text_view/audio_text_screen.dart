import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';
import 'package:utsav_interview/app/audio_text_view/models/paragrah_data_model.dart';
import 'package:utsav_interview/app/audio_text_view/widgets/paragraph_widget.dart';
import 'package:utsav_interview/app/download_novel/download_controller.dart';
import 'package:utsav_interview/app/home_screen/models/novel_model.dart';
import 'package:utsav_interview/app/library_view/library_controller.dart';
import 'package:utsav_interview/app/library_view/library_screen.dart';
import 'package:utsav_interview/app/share_service.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/common_textfield.dart';
import 'package:utsav_interview/core/pref.dart';
import 'package:utsav_interview/routes/app_routes.dart';

import '../../core/common_elevated_button.dart';

class AudioTextScreen extends StatelessWidget {
  const AudioTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioTextController>(
      init: AudioTextController(),
      initState: (state) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            if (Get.arguments != null) {
              if (isAudioInitCount.value == 0) {
                state.controller?.isAllChaptersLoaded = false;
                // state.controller?.uiParagraphs.clear();
                // state.controller?.allParagraphs.clear();
                // state.controller?.update();
                state.controller?.initializeApp();
                isAudioInitCount.value = 1;
              }
            }
            state.controller?.startListening();
          } catch (e) {
            print('Error starting listening: $e');
          }
        });
      },
      builder: (controller) {
        if (controller.hasError) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.colorBlack,
                foregroundColor: AppColors.colorWhite,
                title: Text('Error', style: AppTextStyles.errorText18),
              ),
              body: _buildErrorView(controller),
            ),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.colorBlack,
          appBar:
              controller.isHideText
                  ? null
                  : PreferredSize(
                    preferredSize: const Size.fromHeight(80),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: 110,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(right: 10, left: 16),
                      decoration: BoxDecoration(
                        color: AppColors.colorBlack,
                        boxShadow: [
                          BoxShadow(
                            color: controller.isCollapsed ? AppColors.colorBlack : AppColors.colorTransparent,
                            blurRadius: 50,
                            spreadRadius: 20,
                            offset: Offset(0, 30),
                          ),
                        ],
                      ),

                      child: Row(
                        spacing: 16,
                        // alignment: Alignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          /// --- TOP ROW (Back + Icons) ---
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.colorWhite),
                          ).paddingOnly(bottom: 20),

                          Expanded(
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 400),
                              opacity: controller.isCollapsed ? 1 : 0,
                              child: AnimatedSlide(
                                duration: Duration(milliseconds: 400),
                                curve: Curves.easeOut,
                                offset: controller.isCollapsed ? Offset(0, 0) : Offset(0, 0.3),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 58),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(controller.bookNme ?? "", style: AppTextStyles.body16WhiteMedium, overflow: TextOverflow.ellipsis),
                                      Text(controller.authorNme ?? "", style: AppTextStyles.body14GreyRegular, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.file_upload_outlined),
                                color: AppColors.colorWhite,
                                onPressed: () {
                                  openShareSheet(context);
                                },
                              ),

                              IconButton(
                                icon: Icon(Icons.more_horiz),
                                color: AppColors.colorWhite,
                                onPressed: () {
                                  openAudioTextSettingSheet(context);
                                },
                              ),
                            ],
                          ).paddingOnly(bottom: 5),
                        ],
                      ),
                    ),
                  ),

          body: Stack(
            children: [
              Column(
                children: [
                  if (controller.isLoading) const LinearProgressIndicator(),

                  if (controller.error != null)
                    Container(color: Colors.red[100], padding: const EdgeInsets.all(8), child: Text(controller.error!, style: AppTextStyles.errorText18)),

                  /// -------------------------
                  /// 🔵 Transcript List (Slivers)
                  /// -------------------------
                  Expanded(child: _buildTranscriptView(context, controller)),

                  /// -------------------------
                  /// 🔵 slider, play button, other settings
                  /// -------------------------
                  _buildControlPanel(context, controller),
                ],
              ),

              if (controller.isScrolling && (controller.currentParagraphIndex != -1))
                GetBuilder<AudioTextController>(
                  id: "scrollButton",
                  builder: (controller) {
                    return Positioned(
                      right: 18,
                      bottom: MediaQuery.of(context).size.height * 0.29,
                      child: GestureDetector(
                        onTap: () async {
                          controller.isScrolling = false;
                          controller.update(["scrollButton"]);

                          controller.restoreScrollPosition();
                        },
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 400),
                          opacity: controller.showScrollButton ? 1 : 0,
                          child: AnimatedSlide(
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            offset:
                                controller.showScrollButton
                                    ? Offset(0, 0) // slides UP (visible)
                                    : Offset(0, 0.5), // slides DOWN (hidden)
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                              decoration: BoxDecoration(color: AppColors.colorWhite, borderRadius: BorderRadius.circular(50)),
                              child: Row(
                                children: [Image.asset(CS.icList, color: Colors.black, width: 12), Image.asset(CS.icLeftArrow, color: Colors.black, width: 4)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              Positioned(
                right: 14,
                bottom: MediaQuery.of(context).size.height * 0.22,
                child: Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.colorWhite, borderRadius: BorderRadius.circular(50)),
                  child: Image.asset(CS.icAiChat, color: AppColors.colorBlack, width: 18, height: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// new
  Widget _buildErrorView(AudioTextController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.colorRed),
            const SizedBox(height: 16),
            Text(controller.errorMessage ?? CS.vAnErrorOccurred, textAlign: TextAlign.center, style: AppTextStyles.errorText18),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.hasError = false;
                controller.errorMessage = null;

                controller.initializeApp();
              },
              child: Text(CS.vRetry),
            ),
          ],
        ),
      ),
    );
  }

  /// new
  Widget _buildTranscriptView(context, AudioTextController controller) {
    final paragraphs = controller.uiParagraphs;

    if (paragraphs.isEmpty) {
      return _buildShimmerLoading(context);
    }

    return controller.isHideText
        ? Stack(
          children: [
            /// 🔹 Blur Effect
            controller.isOfflineMode
                ? Image.file(
                  File(controller.fileBookCoverUrl),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                )
                : CachedNetworkImage(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  imageUrl: controller.bookCoverUrl,
                  errorWidget: (context, error, stackTrace) {
                    return Image.asset(
                      CS.imgBookCover2,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    );
                  },
                ),

            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: AppColors.colorBgGray02.withOpacity(0.4), // dark overlay
              ),
            ),

            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    controller.isOfflineMode
                        ? Image.file(File(controller.fileBookCoverUrl ?? ""), height: 260)
                        : CachedNetworkImage(
                          height: 260,
                          imageUrl: controller.bookCoverUrl,
                          errorWidget: (context, error, stackTrace) {
                            return Image.asset(CS.imgBookCover2, height: 260);
                          },
                        ),
              ),
            ),
            Row(
              spacing: 16,
              // alignment: Alignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// --- TOP ROW (Back + Icons) ---
                GestureDetector(onTap: () => Get.back(), child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.colorWhite)).screenPadding(),

                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.file_upload_outlined),
                      color: AppColors.colorWhite,
                      onPressed: () {
                        openShareSheet(context);
                      },
                    ),

                    IconButton(
                      icon: Icon(Icons.more_horiz),
                      color: AppColors.colorWhite,
                      onPressed: () {
                        openAudioTextSettingSheet(context);
                      },
                    ),
                  ],
                ),
              ],
            ).paddingOnly(right: 10, top: 50),
          ],
        )
        : NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // When user scrolls
            if (notification is ScrollUpdateNotification) {
              // if (!controller.isScrolling) {
              //   controller.isScrolling = true;
              //   controller.update();
              // }
              if (controller.scrollController.position.isScrollingNotifier.value) {
                controller.isScrolling = true;
                controller.update();
              } else {
                controller.isScrolling = false;
                controller.update();
              }
            }

            return false;
          },

          child: CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              SliverAppBar(
                pinned: false,
                expandedHeight: 50,
                backgroundColor: AppColors.colorBlack,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  // title: const Text("Audio Text Synchronizer"),
                  background: Container(
                    padding: const EdgeInsets.only(left: 25, bottom: 5),
                    alignment: Alignment.bottomLeft,
                    child: Text(controller.bookNme, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 70),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    // ✅ Track chapter changes
                    int currentChapterIndex = -1;
                    int adjustedIndex = index;

                    // Count chapter headers before this index
                    for (int i = 0; i < paragraphs.length && adjustedIndex >= 0; i++) {
                      if (paragraphs[i].chapterIndex != currentChapterIndex) {
                        if (adjustedIndex == 0) {
                          // Show chapter header
                          currentChapterIndex = paragraphs[i].chapterIndex ?? 0;
                          return Row(
                            children: [
                              // Icon(Icons.library_books, color: AppColors.colorWhite),
                              // SizedBox(width: 12),
                              Text("Chapter ${currentChapterIndex + 1}", style: AppTextStyles.heading20WhiteSemiBold),
                            ],
                          ).paddingSymmetric(horizontal: 10, vertical: 15);
                        }
                        adjustedIndex--;
                        currentChapterIndex = paragraphs[i].chapterIndex ?? 0;
                      }

                      if (adjustedIndex == 0) {
                        // Show paragraph
                        final paragraph = paragraphs[i];

                        // final isCurrentParagraph = i == controller.currentParagraphIndex;
                        // final wordIndexInParagraph =
                        //     isCurrentParagraph && controller.syncEngine != null
                        //         ? controller.syncEngine?.getWordIndexInParagraph(controller.currentWordIndex, i)
                        //         : null;

                        int globalWordStartIndex = 0;
                        for (int p = 0; p < i; p++) {
                          globalWordStartIndex += paragraphs[p].allWords.length;
                        }

                        final isCurrentParagraph = i == controller.currentParagraphIndex;

                        final wordIndexInParagraph = isCurrentParagraph ? controller.currentWordIndex - globalWordStartIndex : null;
                        return ParagraphWidget(
                          paragraph: paragraph,
                          paragraphIndex: i,
                          currentWordIndex: wordIndexInParagraph,
                          isCurrentParagraph: isCurrentParagraph,
                          onWordTap: (start) async {
                            if (paragraphs[i].isBookmarked ?? false) {
                              openBookmarkedSheet(context, start, i);
                            } else {
                              // controller.seek(start);

                              controller.seekToWord(positionMs: start, paragraph: paragraph, wordIndexInParagraph: wordIndexInParagraph ?? 0);
                            }
                          },
                          widgetKey: controller.paragraphKeys[i],
                          controller: controller,
                          globalWordStartIndex: globalWordStartIndex,
                          colorAudioTextBg: controller.colorAudioTextBg,
                          colorAudioTextParagraphBg: controller.colorAudioTextParagraphBg,
                        );
                      }
                      adjustedIndex--;
                    }

                    return SizedBox.shrink();
                  }, childCount: _calculateTotalItems(controller, paragraphs)),
                ),
              ),
            ],
          ),
        );
  }

  int _calculateTotalItems(AudioTextController controller, List<ParagraphData> paragraphs) {
    int count = 0;
    int currentChapter = -1;

    for (var paragraph in paragraphs) {
      // Add chapter header when chapter changes
      if (paragraph.chapterIndex != currentChapter) {
        count++; // Chapter header
        currentChapter = paragraph.chapterIndex ?? -1;
      }
      count++; // Paragraph
    }

    return count;
  }

  /// new
  Widget _buildControlPanel(BuildContext context, AudioTextController controller) {
    // final theme = Theme.of(Get.context!);
    final double max = controller.duration > 0 ? controller.duration.toDouble() : 1.0;

    final value = controller.position.clamp(0, max);

    return Container(
      padding: EdgeInsets.only(top: 10),

      decoration: BoxDecoration(
        color: AppColors.colorBlack,
        boxShadow: [BoxShadow(color: AppColors.colorBlack, blurRadius: 45, spreadRadius: 10, offset: Offset(0, -50))],
        // boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Slider(
              min: 0,
              allowedInteraction: SliderInteraction.slideOnly,
              padding: EdgeInsets.all(5),
              max: max.toDouble(),
              // value: value.toDouble(),
              value: controller.isUserDragging ? controller.sliderPosition : controller.position.toDouble(),
              activeColor: AppColors.colorWhite,
              inactiveColor: AppColors.colorBgGray02,
              overlayColor: WidgetStatePropertyAll(AppColors.colorWhite),

              // onChanged: (value) {
              //   controller.pause();
              //   controller.seek(value.toInt());
              // },
              onChangeStart: (v) {
                controller.isUserDragging = true;
                controller.sliderPosition = v;
                controller.pause();
              },

              onChanged: (v) {
                controller.sliderPosition = v;

                // 🔥 LIVE preview (word + paragraph + scroll)
                controller.previewAndScrollAt(v.toInt());

                controller.update();
              },

              onChangeEnd: (v) async {
                controller.isUserDragging = false;

                // ONE real seek
                await controller.seek(v.toInt(), isPlay: false);
                controller.play();
              },
            ),
          ),

          /// time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Row(
              children: [
                Text(
                  controller.formatTime(controller.isUserDragging ? controller.sliderPosition.toInt() : controller.position),
                  style: AppTextStyles.body12GreyRegular,
                ),
                const Spacer(),
                Text(controller.formatTime(controller.duration), style: AppTextStyles.body12GreyRegular),
              ],
            ),
          ),

          /// play,bookmark,speed
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    controller.bookmark();
                    showBookmarkSavedPopup(context);
                  },
                  child: Image.asset(CS.icBookmark, height: 20, color: AppColors.colorGrey),
                ),

                Spacer(),
                IconButton(
                  icon: Icon(Icons.replay_10_rounded, color: AppColors.colorWhite),
                  iconSize: 32,
                  onPressed: controller.skipBackward,
                  tooltip: '${CS.vSkip} -10s',
                ),
                const SizedBox(width: 16),
                controller.audioLoading
                    ? SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: AppColors.colorWhite, strokeWidth: 3))
                    : IconButton(
                      icon: Icon(controller.isPlaying ? Icons.pause : Icons.play_arrow_rounded, size: 48, color: AppColors.colorWhite),
                      onPressed: controller.togglePlayPause,
                      tooltip: controller.isPlaying ? CS.vPause : CS.vPlay,
                    ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.forward_10_rounded, color: AppColors.colorWhite),
                  iconSize: 32,
                  onPressed: controller.skipForward,
                  tooltip: '${CS.vSkip} +10s',
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    openSpeedControlSheet(context);
                  },
                  child: Text("${formatSpeed(controller.currentSpeed)}x", style: AppTextStyles.body16WhiteRegular),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),

          /// settings
          // Padding(
          //   padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       const SizedBox(width: 16),
          //       GestureDetector(
          //         onTap: () {
          //           Get.toNamed(AppRoutes.voiceScreen);
          //         },
          //         child: Icon(Icons.keyboard_voice_outlined, color: AppColors.colorGrey, size: 30),
          //       ),
          //       GestureDetector(
          //         onTap: () {
          //           openContentsSheet(context);
          //         },
          //         child: Image.asset(CS.icContents, height: 28, color: AppColors.colorGrey),
          //       ),
          //       GestureDetector(
          //         onTap: () {
          //           Get.toNamed(AppRoutes.soundSpacesScreen);
          //         },
          //         child: Image.asset(CS.icVoiceScapes, height: 28, color: AppColors.colorGrey),
          //       ),
          //
          //       const SizedBox(width: 16),
          //     ],
          //   ),
          // ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==========================================================
  // PUBLIC METHOD — CALL THIS
  // ==========================================================
  void openContentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: Get.key.currentContext!,
      backgroundColor: AppColors.colorBgGray02,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder: (_) {
        return GetBuilder<AudioTextController>(
          builder: (controller) {
            return _contentsSheetUI(controller, context);
          },
        );
      },
    );
  }

  // ==========================================================
  // MAIN UI
  // ==========================================================
  Widget _contentsSheetUI(AudioTextController controller, BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: BoxDecoration(
          color: AppColors.colorBgGray02,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_contentsHeader(), const SizedBox(height: 25), _contentsItems(), const SizedBox(height: 35)],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER ROW
  // ==========================================================
  Widget _contentsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.colorBgGray02,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(CS.vContents, style: AppTextStyles.heading18WhiteMedium),
          commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
        ],
      ),
    );
  }

  // ==========================================================
  // CONTENT ITEMS
  // ==========================================================
  Widget _contentsItems() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Chapter 1: The Peace", style: AppTextStyles.body16WhiteMedium, overflow: TextOverflow.ellipsis).paddingSymmetric(horizontal: 20),
            const SizedBox(height: 25),

            Text("Chapter 2: The Night", style: AppTextStyles.body16WhiteMedium, overflow: TextOverflow.ellipsis).paddingSymmetric(horizontal: 20),
            const SizedBox(height: 25),

            Text("Chapter 3: The Morning", style: AppTextStyles.body16WhiteMedium, overflow: TextOverflow.ellipsis).paddingSymmetric(horizontal: 20),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PUBLIC METHOD — CALL THIS
  // ==========================================================
  void openSpeedControlSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.colorBgGray02,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),

      builder: (_) {
        return GetBuilder<AudioTextController>(
          builder: (controller) {
            return _speedSheetUI(controller, context);
          },
        );
      },
    );
  }

  // ==========================================================
  // MAIN BOTTOMSHEET UI
  // ==========================================================
  Widget _speedSheetUI(AudioTextController controller, BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.colorBgGray02,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _speedHeader(controller),
              const SizedBox(height: 25),
              _speedSlider(controller, context),
              const SizedBox(height: 10),
              _speedSliderLabels(),
              const SizedBox(height: 25),
              _speedPresetButtons(controller),
              const SizedBox(height: 25),
              _speedSaveButton(),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================
  Widget _speedHeader(AudioTextController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.colorDialogHeader,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${CS.vReadingSpeed} : ${formatSpeed(controller.currentSpeed)}x", style: AppTextStyles.heading18WhiteSemiBold),
          commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
        ],
      ),
    );
  }

  // ==========================================================
  // SLIDER
  // ==========================================================
  Widget _speedSlider(AudioTextController controller, BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white24,
        trackHeight: 2,
        thumbColor: Colors.white,
        overlayColor: Colors.white24,
        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0),
        showValueIndicator: ShowValueIndicator.always,
        valueIndicatorColor: Colors.white,
        valueIndicatorTextStyle: const TextStyle(color: Colors.black),
      ),
      child: Slider(
        min: 0,
        max: controller.speedSteps.length - 1,
        divisions: controller.speedSteps.length - 1,
        value: controller.currentIndex.toDouble(),
        label: "${controller.speedSteps[controller.currentIndex]}x",
        onChanged: (val) {
          controller.currentIndex = val.round();
          controller.currentSpeed = controller.speedSteps[controller.currentIndex];
          controller.setSpeed(controller.currentSpeed);
          controller.update();
        },
      ),
    );
  }

  // ==========================================================
  // SLIDER LABELS (0.25x — 3x)
  // ==========================================================
  Widget _speedSliderLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("0.25x", style: AppTextStyles.body14Regular),
        Text("1.0x", style: AppTextStyles.body14Regular),
        Text("2.0x", style: AppTextStyles.body14Regular),
        Text("3.0x", style: AppTextStyles.body14Regular),
      ],
    ).paddingSymmetric(horizontal: 25);
  }

  String formatSpeed(double v) {
    if (v % 1 == 0) {
      return v.toInt().toString(); // 1.0 → 1
    }
    return v.toString(); // 0.75 stays 0.75
  }

  // ==========================================================
  // PRESET SPEED BUTTONS
  // ==========================================================
  Widget _speedPresetButtons(AudioTextController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          controller.presetSpeeds.map((v) {
            final selected = (controller.currentSpeed == v);

            return GestureDetector(
              onTap: () {
                // DIRECTLY SET EXACT VALUE
                controller.currentSpeed = v;

                // Find the actual index of this exact value in speedSteps
                int index = controller.speedSteps.indexOf(v);
                if (index != -1) controller.currentIndex = index;

                controller.setSpeed(v);
                controller.update();
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? AppColors.colorWhite : AppColors.colorBgWhite10),
                child: Text("${formatSpeed(v)}x", style: TextStyle(color: selected ? AppColors.colorBlack : AppColors.colorWhite, fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
    ).paddingSymmetric(horizontal: 20);
  }

  // ==========================================================
  // SAVE BUTTON
  // ==========================================================
  Widget _speedSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          Get.back();
        },
        child: Text(CS.vSaveSettings, style: AppTextStyles.button16BlackBold),
      ),
    ).paddingSymmetric(horizontal: 25);
  }

  // ---------------------------------------------------------
  // MAIN METHOD TO CALL
  // ---------------------------------------------------------
  void showBookmarkSavedPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.colorTransparent,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (animationContext, animation, __, ___) {
        return _bookmarkPopupUI(context, animation);
      },
    );
  }

  // ---------------------------------------------------------
  // BOOKMARK POPUP UI
  // ---------------------------------------------------------
  Widget _bookmarkPopupUI(BuildContext context, Animation<double> animation) {
    return SafeArea(
      child: Transform.translate(
        offset: Offset(0, 100 * (1 - animation.value)),
        child: Opacity(
          opacity: animation.value,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.colorChipBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(CS.vBookmarkSaved, style: AppTextStyles.body16WhiteBold).paddingSymmetric(horizontal: 16),

                    const SizedBox(height: 5),

                    Text(CS.vYouCanAccessYourBookmark, style: AppTextStyles.body14GreyRegular).paddingSymmetric(horizontal: 16),

                    Divider(),

                    GestureDetector(
                      onTap: () {
                        Get.back();
                        _openAddNoteSheet(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.edit_rounded, color: AppColors.colorWhite), Text(CS.vAddNote, style: AppTextStyles.body16WhiteBold)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // OPEN ADD NOTE BOTTOMSHEET
  // ---------------------------------------------------------
  void _openAddNoteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.colorBgGray02,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder: (_) {
        return GetBuilder<AudioTextController>(
          builder: (controller) {
            return _addNoteSheetUI(controller, context);
          },
        );
      },
    );
  }

  // ---------------------------------------------------------
  // ADD NOTE BOTTOMSHEET UI
  // ---------------------------------------------------------
  Widget _addNoteSheetUI(AudioTextController controller, BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.colorBgGray02,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- HEADER ----------------
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.colorDialogHeader,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(CS.vAddNote, style: AppTextStyles.heading20WhiteSemiBold),
                      commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ---------------- DESCRIPTION ----------------
                Text(
                  controller.uiParagraphs[controller.currentParagraphIndex].allWords.map((e) => e.word).join(" "),
                  style: AppTextStyles.body16WhiteBold,
                ).paddingSymmetric(horizontal: 20),

                const SizedBox(height: 25),

                // ---------------- TEXTFIELD ----------------
                CommonTextFormField(controller: controller.addNoteController, hint: CS.vWriteNote, maxLines: 6).paddingSymmetric(horizontal: 20),

                const SizedBox(height: 25),

                // ---------------- SAVE BUTTON ----------------
                SizedBox(
                  width: double.infinity,
                  child: CommonElevatedButton(
                    title: CS.vSaveNotes,
                    onTap: () async {
                      controller.addNoteBookmark();
                      Get.back();
                    },
                  ),
                ).paddingSymmetric(horizontal: 25),

                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // Sharebottomsheet
  // ==========================================================
  void openShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: Get.key.currentContext!,
      backgroundColor: AppColors.colorBgGray02,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder: (_) {
        return GetBuilder<AudioTextController>(
          builder: (controller) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.colorBgGray02,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  padding: MediaQuery.of(context).viewInsets,
                  child: Column(
                    // spacing: 10,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 20,
                        children: [
                          (controller.bookCoverUrl.isNotEmpty)
                              ? controller.isOfflineMode
                                  ? Image.file(File(controller.fileBookCoverUrl), height: 80, width: 50, fit: BoxFit.contain)
                                  : Image.network(
                                    controller.bookCoverUrl ?? "",
                                    height: 80,
                                    width: 50,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(color: AppColors.colorGrey, height: 80, width: 50);
                                    },
                                  )
                              : Container(color: AppColors.colorGrey, height: 80, width: 50),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(controller.bookNme ?? "", style: AppTextStyles.heading18WhiteSemiBold),
                                Text(controller.authorNme ?? "", style: AppTextStyles.heading18GreyBold),
                              ],
                            ),
                          ),
                          commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                        ],
                      ).paddingSymmetric(vertical: 20),
                      Divider(color: AppColors.colorBgWhite10),
                      ListTile(
                        onTap: () {
                          ShareService.shareAppWithBook(
                            context: context,
                            bookName: controller.bookNme,
                            authorName: controller.authorNme,
                            bookCoverUrl: controller.bookCoverUrl,
                          );
                        },
                        leading: Image.asset(CS.icShareLink, height: 22),
                        title: Text(CS.vShareLink, style: AppTextStyles.heading18WhiteMedium),
                      ),
                      // ListTile(leading: Image.asset(CS.icMusic, height: 20), title: Text(CS.vShareCurrentClip, style: AppTextStyles.heading18WhiteMedium)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // audio text setting sheet
  // ==========================================================
  void openAudioTextSettingSheet(BuildContext context) {
    showModalBottomSheet(
      context: Get.key.currentContext!,
      backgroundColor: AppColors.colorDialogHeader,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) {
        return GetBuilder<AudioTextController>(
          builder: (controller) {
            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.92,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.colorDialogHeader,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  padding: MediaQuery.of(context).viewInsets,
                  child: Column(
                    // spacing: 10,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 20,
                        children: [
                          controller.isOfflineMode
                              ? Image.file(File(controller.fileBookCoverUrl), height: 40, width: 25, fit: BoxFit.fill)
                              : CachedNetworkImage(
                                height: 40,
                                width: 25,
                                fit: BoxFit.fill,
                                imageUrl: controller.bookCoverUrl,
                                errorWidget: (context, error, stackTrace) {
                                  return Image.asset(
                                    CS.imgBookCover2,
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(controller.bookNme, style: AppTextStyles.heading18WhiteRegular),
                                Text(controller.authorNme, style: AppTextStyles.body14GreyRegular),
                              ],
                            ),
                          ),
                          commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 10, padding: 10),
                        ],
                      ).paddingSymmetric(vertical: 20),
                      Expanded(
                        child: ListView(
                          children: [
                            // Row(
                            //   spacing: 5,
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     buildActionBox(assetPath: CS.icChat, label: CS.vVoiceChat, iconSize: 20),
                            //     buildActionBox(assetPath: CS.icContents, label: CS.vContents, iconSize: 20),
                            //     buildActionBox(assetPath: CS.icSleepTimer, label: CS.vSleepTimer, iconSize: 20),
                            //   ],
                            // ),
                            // SizedBox(height: 20),
                            Divider(color: AppColors.colorGreyDivider),
                            commonListTile(
                              assetPath: controller.isHideText ? CS.icShowList : CS.icHeadphone,
                              title: controller.isHideText ? CS.vShowText : CS.vHideText,
                              onTap: () {
                                Get.back();
                                controller.isHideText = !controller.isHideText;
                                controller.update();
                              },
                            ),
                            commonListTile(
                              assetPath: CS.icPreferences,
                              title: CS.vPreferences,
                              onTap: () {
                                Get.back();
                                openPreferencesSheet(context);
                              },
                            ),
                            // commonListTile(
                            //   icon: Icons.keyboard_voice,
                            //   title: CS.vVoices,
                            //   onTap: () {
                            //     Get.back();
                            //     Get.toNamed(AppRoutes.voiceScreen);
                            //   },
                            // ),
                            // commonListTile(
                            //   assetPath: CS.icVoiceScapes,
                            //   title: CS.vSoundScapes,
                            //   onTap: () {
                            //     Get.back();
                            //     Get.toNamed(AppRoutes.soundSpacesScreen);
                            //   },
                            // ),
                            // commonListTile(assetPath: CS.icPronunciation, title: CS.vPronunciations, onTap: () {}),
                            Divider(color: AppColors.colorGreyDivider),
                            // commonListTile(
                            //   assetPath: CS.icContents,
                            //   title: CS.vContents,
                            //   onTap: () {
                            //     Get.back();
                            //     openContentsSheet(context);
                            //   },
                            // ),
                            commonListTile(
                              assetPath: CS.icBookmark,
                              title: CS.vBookmarks,
                              onTap: () async {
                                controller.listBookmarks = await controller.getBookmarksPrefs();
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => bookmarkBottomSheet(context),
                                );
                              },
                            ),
                            // commonListTile(assetPath: CS.icSearch, title: CS.vSearch, onTap: () {}),
                            commonListTile(
                              assetPath: CS.icShareExport,
                              title: CS.vShare,
                              onTap: () {
                                openShareSheet(context);
                              },
                            ),
                            Divider(color: AppColors.colorGreyDivider),
                            commonListTile(
                              assetPath: CS.icPlus,
                              title: CS.vAddToCollection,
                              onTap: () {
                                Get.back();
                                Get.toNamed(AppRoutes.addToCollection, arguments: {"novelData": controller.novelData ?? bookInfo.value});
                              },
                              imageHeight: 18,
                            ),
                            commonListTile(
                              assetPath: CS.icDownloads,
                              title: CS.vDownload,
                              onTap: () async {
                                final DownloadController downloadController =
                                    Get.isRegistered<DownloadController>() ? Get.find<DownloadController>() : Get.put(DownloadController());

                                await downloadController.downloadNovel(controller.novelData ?? bookInfo.value);
                              },
                              imageHeight: 18,
                            ),
                            commonListTile(
                              assetPath: CS.icDelete,
                              style: AppTextStyles.body14RedRegular,
                              title: CS.vDelete,
                              iconColor: AppColors.colorRed,
                              onTap: () {
                                showDeleteDialog(
                                  context,
                                  onConfirm: () async {
                                    final controller = Get.find<AudioTextController>();
                                    await controller.stopListeningAndDelete();
                                    Get.close(2);
                                    Get.back(result: true);
                                    // controller.pause();
                                    // controller.stopListening();
                                  },
                                );
                              },
                            ),
                            Divider(color: AppColors.colorGreyDivider),
                            commonListTile(assetPath: CS.icReport, title: CS.vReportIssue, onTap: () {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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

  void openPreferencesSheet(BuildContext context) {
    showModalBottomSheet(
      context: Get.key.currentContext!,
      backgroundColor: AppColors.colorBgGray02,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder: (_) {
        return GetBuilder<AudioTextController>(
          builder: (controller) {
            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.92,
                decoration: BoxDecoration(
                  color: AppColors.colorBgGray02,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  padding: MediaQuery.of(context).viewInsets,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(CS.vPreferences, style: AppTextStyles.heading20WhiteSemiBold),
                          commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                        ],
                      ).screenPadding(),
                      const SizedBox(height: 20),
                      Text(CS.vFonts, style: AppTextStyles.body16WhiteBold).screenPadding(),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          openChooseFontsSheet(context);
                        },
                        child:
                            Container(
                              decoration: BoxDecoration(borderRadius: BorderRadiusGeometry.circular(10), border: Border.all(color: AppColors.colorBgWhite10)),
                              child: ListTile(
                                // leading:
                                //     controller.selectedFlag == null
                                //         ? Icon(Icons.language, color: AppColors.colorWhite)
                                //         : Text(controller.selectedFlag ?? "", style: AppTextStyles.heading3),
                                title: Text(
                                  controller.selectedFonts,
                                  style:
                                      controller.selectedFonts == CS.vInter
                                          ? AppTextStyles.body16WhiteMedium
                                          : controller.selectedFonts == CS.vLibreBaskerville
                                          ? AppTextStyles.body16WhiteMediumLibre
                                          : AppTextStyles.body16WhiteMediumOpenSans,
                                ),
                                trailing: Icon(Icons.keyboard_arrow_right_outlined, color: AppColors.colorGrey),
                              ),
                            ).screenPadding(),
                      ),
                      const SizedBox(height: 10),
                      Slider(
                        min: 8,
                        max: 40,
                        thumbColor: AppColors.colorWhite,
                        activeColor: AppColors.colorWhite,
                        inactiveColor: AppColors.colorChipBackground,
                        value: dCurrentAudioTextSize,
                        onChanged: (value) {
                          dCurrentAudioTextSize = value;
                          controller.update();
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(CS.vSmallest, style: AppTextStyles.body12GreyRegular),
                          Text("${dCurrentAudioTextSize.toStringAsFixed(0)}${CS.vPts}", style: AppTextStyles.body12GreyRegular),
                          Text(CS.vLargest, style: AppTextStyles.body12GreyRegular),
                        ],
                      ).screenPadding(),
                      const SizedBox(height: 30),
                      Text(CS.vTheme, style: AppTextStyles.body16WhiteBold).screenPadding(),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(4, (index) {
                            return GestureDetector(
                              onTap: () {
                                if (index == 0) {
                                  controller.iThemeSelect = 0;
                                  controller.colorAudioTextBg = AppColors.colorTealDark;
                                  controller.colorAudioTextParagraphBg = AppColors.colorTealDarkBg;
                                  controller.update();
                                } else if (index == 1) {
                                  controller.iThemeSelect = 1;
                                  controller.colorAudioTextBg = AppColors.colorBrown;
                                  controller.colorAudioTextParagraphBg = AppColors.colorBgBrown;
                                  controller.update();
                                } else if (index == 2) {
                                  controller.iThemeSelect = 2;
                                  controller.colorAudioTextBg = AppColors.colorYellow;
                                  controller.colorAudioTextParagraphBg = AppColors.colorGreyBg;
                                  controller.update();
                                } else {
                                  controller.iThemeSelect = 3;
                                  controller.colorAudioTextBg = AppColors.colorGreen;
                                  controller.colorAudioTextParagraphBg = AppColors.colorGreenLightBg;
                                  controller.update();
                                }
                              },
                              child: Container(
                                width: 100,

                                height: 100,
                                margin: EdgeInsets.all(8),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.colorChipBackground,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: controller.iThemeSelect == index ? AppColors.colorWhite : Colors.transparent),
                                ),
                                child: Image.asset(controller.listThemeImg[index]),
                              ).paddingOnly(left: index == 0 ? 20 : 0),
                            );
                          }),
                        ),
                      ),
                      Spacer(),
                      Row(
                        spacing: 15,
                        children: [
                          Expanded(
                            flex: 1,
                            child: CommonElevatedButton(
                              title: CS.vReset,
                              backgroundColor: AppColors.colorChipBackground,
                              textStyle: AppTextStyles.button16WhiteBold,
                              onTap: () async {
                                controller.selectedFonts = CS.vInter;
                                controller.colorAudioTextBg = AppColors.colorTealDark;
                                controller.colorAudioTextParagraphBg = AppColors.colorTealDarkBg;
                                controller.iThemeSelect = 0;
                                dCurrentAudioTextSize = 16;
                                currentAudioTextFonts = AppFontType.inter;

                                await AppPrefs.remove(CS.keySelectedFont);
                                await AppPrefs.remove(CS.keyAudioTextSize);
                                await AppPrefs.remove(CS.keyThemeIndex);
                                await AppPrefs.remove(CS.keyAudioBgColor);
                                await AppPrefs.remove(CS.keyAudioParagraphBgColor);

                                controller.update();
                              },
                            ),
                          ),
                          Expanded(flex: 2, child: CommonElevatedButton(onTap: () async {
                            await controller.saveSettings();
                          },title: CS.vSaveSettings)),
                        ],
                      ).screenPadding(),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openChooseFontsSheet(BuildContext context) {
    showModalBottomSheet(
      context: Get.key.currentContext!,
      backgroundColor: AppColors.colorBgGray02,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder: (_) {
        return GetBuilder<AudioTextController>(
          builder: (controller) {
            return SafeArea(
              child: Container(
                // height: MediaQuery.of(context).size.height * 0.92,
                decoration: BoxDecoration(
                  color: AppColors.colorBgGray02,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  padding: MediaQuery.of(context).viewInsets,
                  child:
                      Column(
                        // spacing: 20,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(CS.vChooseFont, style: AppTextStyles.heading20WhiteSemiBold),
                              commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                            ],
                          ),
                          SizedBox(height: 20),
                          commonListTile(
                            title: CS.vInter,
                            subtitle: CS.vDummyChooseFontText,
                            style: AppTextStyles.body16WhiteMedium,
                            subtitleStyle: AppTextStyles.body16WhiteLight,
                            onTap: () {
                              Get.back();
                              currentAudioTextFonts = AppFontType.inter;
                              controller.selectedFonts = CS.vInter;
                              controller.update();
                            },
                            isLeading: false,
                            trailing: controller.selectedFonts == CS.vInter ? Icon(Icons.check_circle_rounded, color: AppColors.colorWhite) : SizedBox(),
                          ),
                          Divider(color: AppColors.colorBgWhite10),
                          commonListTile(
                            title: "${CS.vLibreBaskerville}\n${CS.vDummyChooseFontText}",
                            style: AppTextStyles.body16WhiteMediumLibre,
                            subtitleStyle: AppTextStyles.body16WhiteLightLibre,
                            onTap: () {
                              Get.back();
                              currentAudioTextFonts = AppFontType.libreBaskerville;

                              controller.selectedFonts = CS.vLibreBaskerville;
                              controller.update();
                            },
                            isLeading: false,
                            trailing:
                                controller.selectedFonts == CS.vLibreBaskerville ? Icon(Icons.check_circle_rounded, color: AppColors.colorWhite) : SizedBox(),
                          ),

                          Divider(color: AppColors.colorBgWhite10),
                          commonListTile(
                            title: "${CS.vOpenSans}\n${CS.vDummyChooseFontText}",
                            style: AppTextStyles.body16WhiteMediumOpenSans,
                            subtitleStyle: AppTextStyles.body16WhiteLightOpenSans,
                            onTap: () {
                              Get.back();
                              currentAudioTextFonts = AppFontType.openSans;

                              controller.selectedFonts = CS.vOpenSans;
                              controller.update();
                            },
                            isLeading: false,
                            trailing: controller.selectedFonts == CS.vOpenSans ? Icon(Icons.check_circle_rounded, color: AppColors.colorWhite) : SizedBox(),
                          ),

                          SizedBox(height: 20),
                        ],
                      ).screenPadding(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bookmarkBottomSheet(context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(color: AppColors.colorBgGray02, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      padding: EdgeInsets.all(16),

      child: GetBuilder<AudioTextController>(
        init: AudioTextController(),
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(CS.vBookmarks, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                ],
              ),

              SizedBox(height: 12),

              // IF EMPTY
              if (controller.listBookmarks?.isEmpty ?? false)
                Center(child: Text(CS.vNoBookmarksAdded, style: AppTextStyles.body16WhiteMedium))
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: controller.listBookmarks?.length ?? 0,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (_, index) {
                      return Slidable(
                        key: ValueKey(controller.listBookmarks?[index].startTime),

                        endActionPane: ActionPane(
                          motion: DrawerMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (_) async {
                                showDeleteBookmarkDialog(
                                  context,
                                  onPressed: () async {
                                    await controller.deleteBookmark(index);
                                    Get.back();
                                  },
                                );
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: CS.vDelete,
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            SizedBox(height: 5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(controller.listBookmarks?[index].startTime ?? "", style: AppTextStyles.body12GreyRegular),
                                Text("\t-\t", style: AppTextStyles.body12GreyRegular),
                                Text(controller.listBookmarks?[index].endTime ?? "", style: AppTextStyles.body12GreyRegular),
                              ],
                            ),
                            Text(controller.listBookmarks?[index].paragraph ?? "", style: AppTextStyles.body16WhiteBold),
                            if (controller.listBookmarks?[index].note != null && (controller.listBookmarks?[index].note.isNotEmpty ?? false))
                              Text(controller.listBookmarks?[index].note ?? "", style: AppTextStyles.body16GreyMedium),
                            SizedBox(height: 5),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<bool?> showDeleteBookmarkDialog(BuildContext context, {Function()? onPressed}) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return GetBuilder<AudioTextController>(
          init: AudioTextController(),
          builder: (controller) {
            return AlertDialog(
              backgroundColor: AppColors.colorBgGray02,
              title: Text(CS.vDeleteBookmark, style: AppTextStyles.heading20WhiteSemiBold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              content: Text(CS.vDeleteBookmarkWarning, style: AppTextStyles.body16WhiteMedium).paddingOnly(left: 15),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(CS.vCancel, style: AppTextStyles.body16WhiteBold)),
                TextButton(
                  onPressed: onPressed,
                  child:
                      controller.isBookMarkDelete
                          ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.colorWhite))
                          : Text(CS.vDelete, style: AppTextStyles.body16RedBold),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // Bookmarked sheet
  // ==========================================================
  void openBookmarkedSheet(BuildContext context, int start, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.colorBgGray02,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),

      builder: (_) {
        return GetBuilder<AudioTextController>(
          builder: (controller) {
            return SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.colorBgGray02,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  padding: MediaQuery.of(context).viewInsets,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.colorDialogHeader,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(CS.vBookmark, style: AppTextStyles.heading18WhiteSemiBold),
                            commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                          ],
                        ),
                      ),
                      commonListTile(
                        onTap: () {
                          Get.back();
                          controller.seek(start);
                        },
                        title: CS.vListenFromHere,
                        assetPath: CS.icHeadphone,
                        style: AppTextStyles.body16WhiteBold,
                      ),
                      commonListTile(
                        onTap: () {
                          _openAddNoteSheet(context);
                        },
                        title: CS.vEdit,
                        icon: Icons.edit_outlined,
                        style: AppTextStyles.body16WhiteBold,
                      ),
                      commonListTile(
                        onTap: () {
                          showDeleteBookmarkDialog(
                            context,
                            onPressed: () async {
                              try {
                                controller.isBookMarkDelete = true;
                                controller.update();

                                // controller.listBookmarks = await controller.getBookmarksPrefs();

                                for (var p in controller.uiParagraphs) {
                                  if (controller.uiParagraphs[index].id == p.id) {
                                    p.isBookmarked = false;
                                  }
                                }
                                for (var i = 0; i < (controller.listBookmarks?.length ?? 0); i++) {
                                  if (controller.uiParagraphs[index].id == controller.listBookmarks?[i].id) {
                                    controller.listBookmarks?.removeAt(i);
                                  }
                                }
                                controller.update();
                                // save updated list
                                await controller.saveBookmarkList(controller.listBookmarks ?? []);
                              } finally {
                                Get.back();
                                controller.isBookMarkDelete = false;
                                controller.update();
                              }
                              Get.back();
                            },
                          );
                        },
                        title: CS.vDelete,
                        icon: Icons.delete_outline,
                        iconColor: AppColors.colorRed,
                        style: AppTextStyles.body16RedBold,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Widget _buildShimmerLoading(BuildContext context) {
  return Container(
    color: AppColors.colorBlack,
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book title shimmer
          _shimmerBookTitle(),
          SizedBox(height: 32),

          // Chapter title shimmer
          _shimmerChapterTitle(),
          SizedBox(height: 20),

          // Paragraph shimmers (3 paragraphs)
          ..._buildShimmerParagraphs(3),

          SizedBox(height: 10),

          // Another chapter
          _shimmerChapterTitle(),
          SizedBox(height: 20),
          ..._buildShimmerParagraphs(2),
        ],
      ),
    ),
  );
}

Widget _shimmerBookTitle() {
  return Shimmer(
    color: AppColors.colorGrey,
    child: Container(width: 200, height: 28, decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(6))),
  );
}

Widget _shimmerChapterTitle() {
  return Shimmer(
    color: AppColors.colorGrey,
    child: Container(width: 140, height: 22, decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(6))),
  );
}

List<Widget> _buildShimmerParagraphs(int count) {
  return List.generate(count, (index) {
    return Padding(padding: EdgeInsets.only(bottom: 20), child: _shimmerParagraph(index));
  });
}

Widget _shimmerParagraph(int index) {
  return Shimmer(
    colorOpacity: index == 0 ? 0.3 : 0,
    color: index == 0 ? AppColors.colorGrey : AppColors.colorTransparent,

    child: Container(
      padding: EdgeInsets.all(index == 0 ? 20 : 5),
      decoration: BoxDecoration(color: index == 0 ? Colors.grey[850] : null, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line 1 (100%)
          _shimmerLine(widthFactor: 1.0),
          SizedBox(height: 12),

          // Line 2 (95%)
          _shimmerLine(widthFactor: 0.95),
          SizedBox(height: 12),

          // Line 3 (88%)
          _shimmerLine(widthFactor: 0.88),
          SizedBox(height: 12),

          // Line 4 (92%)
          _shimmerLine(widthFactor: 0.92),
          SizedBox(height: 12),

          // Line 5 (65%)
          _shimmerLine(widthFactor: 0.65),
        ],
      ),
    ),
  );
}

Widget _shimmerLine({required double widthFactor}) {
  return Shimmer(
    color: AppColors.colorGrey,
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth * widthFactor,
          height: 14,
          decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(4)),
        );
      },
    ),
  );
}
