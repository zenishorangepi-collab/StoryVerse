import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_screen/audio_text_controller.dart';
import 'package:utsav_interview/app/audio_text_screen/widgets/paragraph_widget.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';

class AudioTextScreen extends StatelessWidget {
  const AudioTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AudioTextController>(
      init: AudioTextController(),
      builder: (controller) {
        if (controller.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: _buildErrorView(controller),
          );
        }
        return  Scaffold(
          backgroundColor: AppColors.colorBlack,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,

              height:  80 ,
              padding: const EdgeInsets.symmetric(horizontal: 16),

              decoration: const BoxDecoration(
                color: AppColors.colorBlack,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),

              child: Row(
          
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

Icon(Icons.keyboard_arrow_down_rounded,color: AppColors.colorWhite,),

                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    left: 0,
                    top: controller.isCollapsed ? 18 : -40,
                    child: Opacity(
                      opacity: controller.isCollapsed ? 1 : 0,
                      child:  AnimatedSlide(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        offset: controller.isCollapsed ? Offset(0, 0) : Offset(0, 0.3), // ↓ start, ↑ end
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 500),
                          opacity: controller.isCollapsed ? 1 : 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Audio Text Synchronizer",
                                style: AppTextStyles.bodyLarge,
                              ),
                              Text(
                                "Subtitle text",
                                style: AppTextStyles.bodyMediumGrey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.cloud_upload_outlined,color: AppColors.colorWhite,),
                  Icon(Icons.more_horiz,color: AppColors.colorWhite,),
                ],
              ),
            ),
          ),

          body: Column(
            children: [
              if (controller.isLoading) const LinearProgressIndicator(),

              if (controller.error != null)
                Container(
                  color: Colors.red[100],
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    controller.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),



              Expanded(
                child: _buildTranscriptView(controller),
              ),

              _buildControlPanel(controller),
            ],
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage ?? CS.vAnErrorOccurred,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
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

    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: paragraphs.length,
      itemBuilder: (context, index) {
        final paragraph = paragraphs[index];

        final isCurrentParagraph = index == controller.currentParagraphIndex;
        final wordIndexInParagraph =
            isCurrentParagraph && controller.syncEngine != null
                ? controller.syncEngine?.getWordIndexInParagraph(
                  controller.currentWordIndex,
                  index,
                )
                : null;

        return ParagraphWidget(
          paragraph: paragraph,
          paragraphIndex: index,
          currentWordIndex: wordIndexInParagraph,
          isCurrentParagraph: isCurrentParagraph,
          onWordTap: (start) => controller.seek(start),
          widgetKey: controller.paragraphKeys[index],
        );
      },
    );
  }

  Widget _buildControlPanel(AudioTextController controller) {
    // final theme = Theme.of(Get.context!);

    return Container(
      padding: EdgeInsets.only(top: 20),

      decoration: BoxDecoration(
        color: AppColors.colorBlack,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(

              min: 0,padding: EdgeInsets.all(0),
              max: controller.duration.toDouble(),
              value: controller.position.toDouble(),
              activeColor: AppColors.colorWhite,inactiveColor: AppColors.colorBgWhite02,overlayColor: WidgetStatePropertyAll(AppColors.colorWhite),
              onChanged: (value) {
                controller.seek(value.toInt());
              },

            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              children: [
                Text(
                  controller.formatTime(controller.position),
                  style: AppTextStyles.bodyMedium,
                ),
                const Spacer(),
                Text(
                  controller.formatTime(controller.duration),
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                Icon(Icons.favorite_border,color: AppColors.colorGrey,size: 26,),
                Spacer(),
                IconButton(
                  icon:  Icon(Icons.replay_10,color: AppColors.colorWhite,),
                  iconSize: 32,
                  onPressed: controller.skipBackward,
                  tooltip: '${CS.vSkip} -10s',
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    controller.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 48,color: AppColors.colorWhite,
                  ),
                  onPressed: controller.togglePlayPause,
                  tooltip: controller.isPlaying ? CS.vPause : CS.vPlay,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.forward_10,color: AppColors.colorWhite,),
                  iconSize: 32,
                  onPressed: controller.skipForward,
                  tooltip: '${CS.vSkip} +10s',
                ),
             Spacer(),
                Text("1x",style: AppTextStyles.bodyMediumGrey16,),
                const SizedBox(width: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(width: 16),
                Icon(Icons.person,color: AppColors.colorGrey,size: 30,),
                Icon(Icons.menu,color: AppColors.colorGrey,size: 30,),
                Icon(Icons.volume_down,color: AppColors.colorGrey,size: 30,),


                const SizedBox(width: 16),
              ],
            ),
          ),
          SizedBox(height: 40,)
        ],
      ),
    );
  }
}
