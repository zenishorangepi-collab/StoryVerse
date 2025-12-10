import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';
import 'package:utsav_interview/app/audio_text_view/widgets/paragraph_widget.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';
import 'package:utsav_interview/core/common_textfield.dart';
import 'package:utsav_interview/routes/app_routes.dart';

import '../../core/common_elevated_button.dart';

class AudioTextScreen extends StatelessWidget {
  const AudioTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioTextController>(
      init: AudioTextController(),
      builder: (controller) {
        if (controller.hasError) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: AppColors.colorBg,
              appBar: AppBar(
                backgroundColor: AppColors.colorBlack,
                foregroundColor: AppColors.colorWhite,
                title: Text('Error', style: AppTextStyles.errorText18),
              ),
              body: _buildErrorView(controller),
            ),
          );
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
                          IconButton(
                            icon: Icon(Icons.file_upload_outlined),
                            color: AppColors.colorWhite,
                            onPressed: () {
                              openShareSheet(context);
                            },
                          ),
                          SizedBox(width: 12),
                          IconButton(
                            icon: Icon(Icons.more_horiz),
                            color: AppColors.colorWhite,
                            onPressed: () {
                              openAudioTextSettingSheet(context);
                            },
                          ),
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
                /// 🔵 Transcript List (Slivers)
                /// -------------------------
                Expanded(child: _buildTranscriptView(controller)),

                /// -------------------------
                /// 🔵 slider, play button, other settings
                /// -------------------------
                _buildControlPanel(context, controller),
              ],
            ),
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
  Widget _buildTranscriptView(AudioTextController controller) {
    final paragraphs = controller.transcript?.paragraphs;

    if (paragraphs == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
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
              child: Text(CS.vAudioTextSynchronizer, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
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

              int globalWordStartIndex = 0;
              for (int p = 0; p < index; p++) {
                globalWordStartIndex += paragraphs[p].words.length;
              }

              return ParagraphWidget(
                paragraph: paragraph,
                paragraphIndex: index,
                currentWordIndex: wordIndexInParagraph,
                isCurrentParagraph: isCurrentParagraph,
                onWordTap: (start) => controller.seek(start),
                widgetKey: controller.paragraphKeys[index],
                controller: controller,
                globalWordStartIndex: globalWordStartIndex, // NEW
              );
            }, childCount: paragraphs.length),
          ),
        ),
      ],
    );
  }

  /// new
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
              inactiveColor: AppColors.colorBgGray02,
              overlayColor: WidgetStatePropertyAll(AppColors.colorWhite),
              onChanged: (value) {
                controller.pause();
                controller.seek(value.toInt());
              },
            ),
          ),

          /// time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Row(
              children: [
                Text(controller.formatTime(controller.position), style: AppTextStyles.bodyMediumGrey),
                const Spacer(),
                Text(controller.formatTime(controller.duration), style: AppTextStyles.bodyMediumGrey),
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
                IconButton(
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
                  child: Text("${formatSpeed(controller.currentSpeed)}x", style: AppTextStyles.bodyLarge),
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
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.voiceScreen);
                  },
                  child: Icon(Icons.person_outline, color: AppColors.colorGrey, size: 30),
                ),
                GestureDetector(
                  onTap: () {
                    openContentsSheet(context);
                  },
                  child: Image.asset(CS.icContents, height: 28, color: AppColors.colorGrey),
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.soundSpacesScreen);
                  },
                  child: Image.asset(CS.icVoiceScapes, height: 28, color: AppColors.colorGrey),
                ),

                const SizedBox(width: 16),
              ],
            ),
          ),
          SizedBox(height: 10),
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
          Text(CS.vContents, style: AppTextStyles.heading3),
          commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
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
        color: AppColors.colorDialogHeaderGray,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${CS.vReadingSpeed} : ${formatSpeed(controller.currentSpeed)}x", style: AppTextStyles.heading4),
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
        Text("0.25x", style: AppTextStyles.bodyMedium),
        Text("1.0x", style: AppTextStyles.bodyMedium),
        Text("2.0x", style: AppTextStyles.bodyMedium),
        Text("3.0x", style: AppTextStyles.bodyMedium),
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
                  color: AppColors.colorBgDialog,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- HEADER ----------------
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.colorDialogHeaderGray,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(CS.vAddNote, style: AppTextStyles.heading3),
                    commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
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
              SizedBox(width: double.infinity, child: CommonElevatedButton(title: CS.vSaveSettings)).paddingSymmetric(horizontal: 25),

              const SizedBox(height: 35),
            ],
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
                          Container(color: AppColors.colorGrey, height: 80, width: 50),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("dummy When khushal returned", style: AppTextStyles.heading4),
                                Text("dummy Saraban", style: AppTextStyles.bodyMediumGrey),
                              ],
                            ),
                          ),
                          commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 12, padding: 12),
                        ],
                      ).paddingSymmetric(vertical: 20),
                      Divider(color: AppColors.colorBgWhite10),
                      ListTile(leading: Image.asset(CS.icShareLink, height: 22), title: Text(CS.vShareLink, style: AppTextStyles.heading4Normal18White)),
                      ListTile(leading: Image.asset(CS.icMusic, height: 20), title: Text(CS.vShareCurrentClip, style: AppTextStyles.heading4Normal18White)),
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
      backgroundColor: AppColors.colorDialogHeaderGray,
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
                  color: AppColors.colorDialogHeaderGray,
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
                          Container(color: AppColors.colorGrey, height: 40, width: 25),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("dummy When khushal returned", style: AppTextStyles.heading4Normal18White),
                                Text("dummy Saraban", style: AppTextStyles.bodyMediumGrey),
                              ],
                            ),
                          ),
                          commonCircleButton(onTap: () => Get.back(), iconPath: CS.icClose, iconSize: 10, padding: 10),
                        ],
                      ).paddingSymmetric(vertical: 20),
                      Expanded(
                        child: ListView(
                          children: [
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildActionBox(assetPath: CS.icChat, label: CS.vVoiceChat),
                                buildActionBox(assetPath: CS.icContents, label: CS.vContents),
                                buildActionBox(assetPath: CS.icSleepTimer, label: CS.vSleepTimer),
                              ],
                            ),
                            SizedBox(height: 20),
                            commonListTile(assetPath: CS.icHeadphone, title: CS.vHideText, onTap: () {}),
                            commonListTile(assetPath: CS.icPreferences, title: CS.vPreferences, onTap: () {}),
                            commonListTile(icon: Icons.keyboard_voice, title: CS.vVoices, onTap: () {}),
                            commonListTile(assetPath: CS.icVoiceScapes, title: CS.vSoundScapes, onTap: () {}),
                            commonListTile(assetPath: CS.icPronunciation, title: CS.vPronunciations, onTap: () {}),
                            Divider(color: AppColors.colorGrey900),
                            commonListTile(assetPath: CS.icContents, title: CS.vContents, onTap: () {}),
                            commonListTile(assetPath: CS.icBookmark, title: CS.vBookmarks, onTap: () {}),
                            commonListTile(assetPath: CS.icSearch, title: CS.vSearch, onTap: () {}),
                            commonListTile(assetPath: CS.icShareExport, title: CS.vShare, onTap: () {}),
                            Divider(color: AppColors.colorGrey900),
                            commonListTile(assetPath: CS.icPlus, title: CS.vAddToCollection, onTap: () {}, imageHeight: 18),
                            commonListTile(assetPath: CS.icDownloads, title: CS.vDownload, onTap: () {}, imageHeight: 18),
                            commonListTile(
                              assetPath: CS.icDelete,
                              style: AppTextStyles.bodyLargeRed6,
                              title: CS.vDelete,
                              iconColor: AppColors.colorRed,
                              onTap: () {
                                showDeleteDialog(context, onConfirm: () {});
                              },
                            ),
                            Divider(color: AppColors.colorGrey900),
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

  Widget commonListTile({
    String? assetPath,
    required String title,
    VoidCallback? onTap,
    IconData? icon,
    double? imageHeight,
    TextStyle? style,
    Color? iconColor,
  }) {
    return ListTile(
      minTileHeight: 50,
      leading: assetPath == null ? Icon(icon, color: AppColors.colorWhite) : Image.asset(assetPath ?? "", height: imageHeight ?? 22, color: iconColor),
      title: Text(title, style: style ?? AppTextStyles.bodyLargeWhite16),
      onTap: onTap,
    );
  }

  Future<void> showDeleteDialog(BuildContext context, {required VoidCallback onConfirm}) {
    return showDialog(
      context: context,
      barrierDismissible: true,

      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.colorBgGray02,
          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(CS.vConfirmDeletion, style: AppTextStyles.bodyLarge),
          content: Text(CS.vYouWillNoLonger, style: AppTextStyles.bodyLargeWhite16),
          actionsAlignment: MainAxisAlignment.end,
          // right side buttons
          actions: [
            TextButton(
              style: ButtonStyle(overlayColor: WidgetStatePropertyAll(AppColors.colorTransparent)),
              onPressed: () => Navigator.pop(context),
              child: Text(CS.vDismiss, style: AppTextStyles.bodyLargeWhite16),
            ),
            TextButton(
              style: ButtonStyle(overlayColor: WidgetStatePropertyAll(AppColors.colorTransparent)),
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Text(CS.vConfirm, style: AppTextStyles.bodyLargeRed6),
            ),
          ],
        );
      },
    );
  }
}
