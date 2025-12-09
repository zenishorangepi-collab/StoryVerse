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

  const ParagraphWidget({
    required this.paragraph,
    required this.paragraphIndex,
    required this.currentWordIndex,
    required this.isCurrentParagraph,
    required this.onWordTap,
    required this.controller,
    required this.widgetKey,
    required this.globalWordStartIndex,
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: widget.isCurrentParagraph ? AppColors.colorBlue200 : Colors.transparent, borderRadius: BorderRadius.circular(8)),
      child: Wrap(spacing: 4, runSpacing: 4, children: _buildWordWidgets(isDark)),
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
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(color: isCurrentWord ? AppColors.colorBlue500 : Colors.transparent, borderRadius: BorderRadius.circular(4)),
            child: Text(word.word, style: AppTextStyles.heading4),
          ),
        ),
      );
    }).toList();
  }
}
