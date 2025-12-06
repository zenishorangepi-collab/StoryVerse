import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';
import 'package:utsav_interview/app/audio_text_view/widgets/paragraph_widget.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/common_textfield.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class AudioTextScreen extends StatelessWidget {
  const AudioTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioTextController>(
      init: AudioTextController(),
      builder: (controller) {
        if (controller.hasError) {
          return Scaffold(appBar: AppBar(title: const Text('Error')), body: _buildErrorView(controller));
        }
        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.colorBlack,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 70,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.colorBlack,
                  boxShadow: [
                    BoxShadow(
                      color: controller.isCollapsed ? AppColors.colorBlack800 : AppColors.colorTransparent,
                      blurRadius: 25,
                      spreadRadius: 5,
                      offset: Offset(0, 15),
                    ),
                  ],
                ),

                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// --- TOP ROW (Back + Icons) ---
                    Positioned(
                      left: 0,
                      child: GestureDetector(onTap: () => Get.back(), child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.colorWhite)),
                    ),
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      left: 40,
                      top: controller.isCollapsed ? 12 : 40,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 400),
                        opacity: controller.isCollapsed ? 1 : 0,
                        child: AnimatedSlide(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          offset: controller.isCollapsed ? Offset(0, 0) : Offset(0, 0.3),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(CS.vAudioTextSynchronizer, style: AppTextStyles.heading4),
                              Text("Subtitle text", style: AppTextStyles.bodyMediumGrey),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 0,
                      child: Row(
                        children: [
                          Icon(Icons.cloud_upload_outlined, color: AppColors.colorWhite),
                          SizedBox(width: 12),
                          Icon(Icons.more_horiz, color: AppColors.colorWhite),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            body: Column(
              children: [
                if (controller.isLoading) const LinearProgressIndicator(),

                if (controller.error != null)
                  Container(color: Colors.red[100], padding: const EdgeInsets.all(8), child: Text(controller.error!, style: AppTextStyles.errorText18)),

                /// -------------------------
                /// 🔵 SliverAppBar inserted here
                /// -------------------------
                Expanded(
                  child: NestedScrollView(
                    controller: controller.scrollController,
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
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
                              child: Text(CS.vAudioTextSynchronizer, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ];
                    },

                    /// Transcript List (Slivers)
                    body: _buildTranscriptView(controller),
                  ),
                ),

                _buildControlPanel(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(AudioTextController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.colorRed),
            const SizedBox(height: 16),
            Text(controller.errorMessage ?? CS.vAnErrorOccurred, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
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

  Widget _buildTranscriptView(AudioTextController controller) {
    final paragraphs = controller.transcript?.paragraphs;

    if (paragraphs == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final paragraph = paragraphs[index];

              final isCurrentParagraph = index == controller.currentParagraphIndex;
              final wordIndexInParagraph =
                  isCurrentParagraph && controller.syncEngine != null
                      ? controller.syncEngine?.getWordIndexInParagraph(controller.currentWordIndex, index)
                      : null;

              return ParagraphWidget(
                paragraph: paragraph,
                paragraphIndex: index,
                currentWordIndex: wordIndexInParagraph,
                isCurrentParagraph: isCurrentParagraph,
                onWordTap: (start) => controller.seek(start),
                widgetKey: controller.paragraphKeys[index],
              );
            }, childCount: paragraphs.length),
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel(BuildContext context, AudioTextController controller) {
    // final theme = Theme.of(Get.context!);

    return Container(
      padding: EdgeInsets.only(top: 10),

      decoration: BoxDecoration(
        color: AppColors.colorBlack,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              min: 0,
              allowedInteraction: SliderInteraction.slideOnly,
              padding: EdgeInsets.all(5),
              max: controller.duration.toDouble(),
              value: controller.position.toDouble(),
              activeColor: AppColors.colorWhite,
              inactiveColor: AppColors.colorBgWhite02,
              overlayColor: WidgetStatePropertyAll(AppColors.colorWhite),

              // onChangeStart: (value) {
              //   // user started dragging: suppress auto-scroll
              //   controller.userScrolling = true;
              //   controller.suppressAutoScroll = true; // if field is private, add a public method
              // },
              onChanged: (value) {
                // live-seek while dragging, call seek(fromUser: true)
                controller.pause();

                controller.seek(value.toInt(), fromUser: true);
              },
              // onChangeEnd: (value) {
              //   // user released slider — final seek + re-enable auto-scroll will happen inside seek()
              //   controller.seek(value.toInt(), fromUser: true);
              // },
            ),
          ),

          /// time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              children: [
                Text(controller.formatTime(controller.position), style: AppTextStyles.bodyMedium),
                const Spacer(),
                Text(controller.formatTime(controller.duration), style: AppTextStyles.bodyMedium),
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
                    showBookmarkSavedPopup(context);
                  },
                  child: const Icon(Icons.bookmark_border, size: 24, color: AppColors.colorGrey),
                ),

                Spacer(),
                IconButton(
                  icon: Icon(Icons.replay_10, color: AppColors.colorWhite),
                  iconSize: 32,
                  onPressed: controller.skipBackward,
                  tooltip: '${CS.vSkip} -10s',
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(controller.isPlaying ? Icons.pause : Icons.play_arrow, size: 48, color: AppColors.colorWhite),
                  onPressed: controller.togglePlayPause,
                  tooltip: controller.isPlaying ? CS.vPause : CS.vPlay,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.forward_10, color: AppColors.colorWhite),
                  iconSize: 32,
                  onPressed: controller.skipForward,
                  tooltip: '${CS.vSkip} +10s',
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    openSpeedControlSheet(context);
                  },
                  child: Text("${controller.currentSpeed.toStringAsFixed(2)}x", style: AppTextStyles.bodyMediumGrey16),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),

          /// settings
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(width: 16),
                Icon(Icons.person, color: AppColors.colorGrey, size: 30),
                GestureDetector(
                  onTap: () {
                    openContentsSheet(context);
                  },
                  child: Icon(Icons.menu, color: AppColors.colorGrey, size: 30),
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.soundSpacesScreen);
                  },
                  child: Icon(Icons.volume_down, color: AppColors.colorGrey, size: 30),
                ),

                const SizedBox(width: 16),
              ],
            ),
          ),
          SizedBox(height: 40),
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
      backgroundColor: Colors.transparent,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorGrey900,
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
    );
  }

  // ==========================================================
  // HEADER ROW
  // ==========================================================
  Widget _contentsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.colorBgWhite10,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(CS.vContents, style: AppTextStyles.heading3),
          GestureDetector(onTap: () => Get.back(), child: const Icon(Icons.cancel, color: Colors.white, size: 28)),
        ],
      ),
    );
  }

  // ==========================================================
  // CONTENT ITEMS
  // ==========================================================
  Widget _contentsItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Chapter 1: The Peace", style: AppTextStyles.bodyLarge).paddingSymmetric(horizontal: 20),
        const SizedBox(height: 25),

        Text("Chapter 2: The Night", style: AppTextStyles.bodyLarge).paddingSymmetric(horizontal: 20),
        const SizedBox(height: 25),

        Text("Chapter 3: The Morning", style: AppTextStyles.bodyLarge).paddingSymmetric(horizontal: 20),
        const SizedBox(height: 25),
      ],
    );
  }

  // ==========================================================
  // PUBLIC METHOD — CALL THIS
  // ==========================================================
  void openSpeedControlSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorGrey900,
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
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================
  Widget _speedHeader(AudioTextController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.colorBgWhite10,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${CS.vReadingSpeed} : ${controller.currentSpeed.toStringAsFixed(2)}x", style: AppTextStyles.heading4),
          GestureDetector(onTap: () => Get.back(), child: const Icon(Icons.cancel, color: Colors.white, size: 28)),
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
        Text("0.25x", style: AppTextStyles.bodyMedium),
        Text("1.0x", style: AppTextStyles.bodyMedium),
        Text("2.0x", style: AppTextStyles.bodyMedium),
        Text("3.0x", style: AppTextStyles.bodyMedium),
      ],
    ).paddingSymmetric(horizontal: 25);
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
                int nearestIndex = controller.speedSteps
                    .map((e) => (e - v).abs())
                    .toList()
                    .indexOf(controller.speedSteps.map((e) => (e - v).abs()).reduce(min));

                controller.currentIndex = nearestIndex;
                controller.currentSpeed = controller.speedSteps[nearestIndex];
                controller.setSpeed(v);
                controller.update();
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? AppColors.colorWhite : AppColors.colorBgWhite10),
                child: Text("${v}x", style: TextStyle(color: selected ? AppColors.colorBlack : AppColors.colorWhite, fontWeight: FontWeight.w600)),
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
        child: Text(CS.vSaveSettings, style: AppTextStyles.buttonTextBlack),
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
    return Transform.translate(
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
                color: AppColors.colorGrey900,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(CS.vBookmarkSaved, style: AppTextStyles.bodyLarge).paddingSymmetric(horizontal: 16),

                  const SizedBox(height: 5),

                  Text(CS.vYouCanAccessYourBookmark, style: AppTextStyles.bodyMediumGrey).paddingSymmetric(horizontal: 16),

                  Divider(),

                  GestureDetector(
                    onTap: () => _openAddNoteSheet(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.edit_rounded, color: AppColors.colorWhite), Text(CS.vAddNote, style: AppTextStyles.bodyLarge)],
                    ),
                  ),
                ],
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
      backgroundColor: Colors.transparent,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorGrey900,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- HEADER ----------------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.colorBgWhite10,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(CS.vAddNote, style: AppTextStyles.heading3),
                  GestureDetector(onTap: () => Get.back(), child: const Icon(Icons.cancel, color: Colors.white, size: 28)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- DESCRIPTION ----------------
            Text("Level II is an intensive workshop for experienced writers...", style: AppTextStyles.bodyLarge).paddingSymmetric(horizontal: 20),

            const SizedBox(height: 25),

            // ---------------- TEXTFIELD ----------------
            CommonTextFormField(controller: controller.addNoteController, hint: CS.vWriteNote, maxLines: 6).paddingSymmetric(horizontal: 20),

            const SizedBox(height: 25),

            // ---------------- SAVE BUTTON ----------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // TODO: save note
                  Get.back();
                },
                child: Text(CS.vSaveSettings, style: AppTextStyles.buttonTextBlack),
              ),
            ).paddingSymmetric(horizontal: 25),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}
