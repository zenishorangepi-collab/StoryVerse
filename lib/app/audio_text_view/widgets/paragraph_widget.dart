import 'package:flutter/material.dart';
import 'package:utsav_interview/app/audio_text_view/audio_text_controller.dart';
import 'package:utsav_interview/app/audio_text_view/models/paragrah_data_model.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_style.dart';

class ParagraphWidget extends StatefulWidget {
  final ParagraphData paragraph;
  final AudioTextController controller;
  final int paragraphIndex;
  final int? currentWordIndex;
  final bool isCurrentParagraph;
  final Function(int) onWordTap;
  final GlobalKey widgetKey;

  const ParagraphWidget({
    required this.paragraph,
    required this.paragraphIndex,
    required this.currentWordIndex,
    required this.isCurrentParagraph,
    required this.onWordTap,
    required this.widgetKey,
    required this.controller,
    super.key,
  });

  @override
  State<ParagraphWidget> createState() => _ParagraphWidgetState();
}

class _ParagraphWidgetState extends State<ParagraphWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      key: widget.widgetKey,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isCurrentParagraph ? AppColors.colorBlue200 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        // border: widget.isCurrentParagraph
        //     ? Border(left: BorderSide(color: theme.primaryColor, width: 3))
        //     : null,
      ),
      child: Wrap(spacing: 4, runSpacing: 4, children: _buildWordWidgets(isDark)),
    );
  }

  List<Widget> _buildWordWidgets(bool isDark) {
    return widget.paragraph.words.asMap().entries.map((entry) {
      final index = entry.key;
      final word = entry.value;
      final isCurrentWord = index == widget.currentWordIndex;

      final wordKey = GlobalKey();
      // widget.controller.wordKeys.add(wordKey);

      return GestureDetector(
        key: wordKey,
        onTap: () => widget.onWordTap(word.start),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          decoration: BoxDecoration(color: isCurrentWord ? AppColors.colorBlue500 : Colors.transparent, borderRadius: BorderRadius.circular(4)),
          child: Text(word.word, style: AppTextStyles.heading4),
        ),
      );
    }).toList();
  }
}
