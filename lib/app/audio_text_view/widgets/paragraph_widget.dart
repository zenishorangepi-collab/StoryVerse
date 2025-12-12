import 'package:flutter/material.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';
import 'package:utsav_interview/app/audio_text_view/models/paragrah_data_model.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_style.dart';

class ParagraphWidget extends StatefulWidget {
  final ParagraphData paragraph;
  final int paragraphIndex;
  final int? currentWordIndex;
  final bool isCurrentParagraph;
  final Function(int) onWordTap;
  final AudioTextController controller;
  final GlobalKey widgetKey;
  final int globalWordStartIndex;
  final Color? colorAudioTextParagraphBg;
  final Color? colorAudioTextBg;

  const ParagraphWidget({
    required this.paragraph,
    required this.paragraphIndex,
    required this.currentWordIndex,
    required this.isCurrentParagraph,
    required this.onWordTap,
    required this.controller,
    required this.widgetKey,
    required this.globalWordStartIndex,
    required this.colorAudioTextParagraphBg,
    required this.colorAudioTextBg,
    super.key,
  });

  @override
  State<ParagraphWidget> createState() => _ParagraphWidgetState();
}

class _ParagraphWidgetState extends State<ParagraphWidget> {
  late final List<GlobalKey> wordKeys; // NEW: Word keys for this paragraph

  @override
  void initState() {
    super.initState();
    wordKeys = List.generate(widget.paragraph.words.length, (index) => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      key: widget.widgetKey,
      padding: const EdgeInsets.all(6),
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: widget.isCurrentParagraph ? widget.colorAudioTextParagraphBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(spacing: 3, runSpacing: 3, children: _buildWordWidgets(isDark)),
    );
  }

  List<Widget> _buildWordWidgets(bool isDark) {
    return widget.paragraph.words.asMap().entries.map((entry) {
      final localIndex = entry.key;
      final word = entry.value;

      // COMPARE LOCAL INDEX (currentWordIndex is now local from screen)
      final isCurrentWord = localIndex == widget.currentWordIndex;

      return Container(
        key: widget.controller.wordKeys[widget.globalWordStartIndex + localIndex],
        child: GestureDetector(
          onTap: () => widget.onWordTap(word.start),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
            decoration: BoxDecoration(color: isCurrentWord ? widget.colorAudioTextBg : Colors.transparent, borderRadius: BorderRadius.circular(4)),
            child: Text(word.word, style: AppTextStyles.font(color: AppColors.colorWhite)),
          ),
        ),
      );
    }).toList();
  }
}
