import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utsav_interview/app/audio_text_screen/audio_text_controller.dart';
import 'package:utsav_interview/app/audio_text_screen/widgets/paragraph_widget.dart';
import 'package:utsav_interview/core/common_string.dart';

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
        return Scaffold(
          appBar: AppBar(title: Text(CS.vAudioTextSynchronizer), elevation: 2),
          body: Stack(
            children: [
              Column(
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
                  Expanded(child: _buildTranscriptView(controller)),
                  _buildControlPanel(controller),
                ],
              ),
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
    final theme = Theme.of(Get.context!);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  controller.formatTime(controller.position),
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  controller.formatTime(controller.duration),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  iconSize: 32,
                  onPressed: controller.skipBackward,
                  tooltip: '${CS.vSkip} -10s',
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    controller.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 48,
                  ),
                  onPressed: controller.togglePlayPause,
                  tooltip: controller.isPlaying ? CS.vPause : CS.vPlay,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  iconSize: 32,
                  onPressed: controller.skipForward,
                  tooltip: '${CS.vSkip} +10s',
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
