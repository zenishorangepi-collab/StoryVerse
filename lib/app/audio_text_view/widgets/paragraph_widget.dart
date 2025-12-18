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
      child: Wrap(spacing: 3, runSpacing: 3, children: _buildLineWidgets()),
    );
  }

  List<Widget> _buildLineWidgets() {
    List<Widget> lineWidgets = [];
    List<Widget> currentLine = [];
    double? currentLineTop;

    for (int i = 0; i < widget.paragraph.words.length; i++) {
      final word = widget.paragraph.words[i];
      final localIndex = i;

      final key = widget.controller.wordKeys[widget.globalWordStartIndex + localIndex];
      final wordWidget = Container(
        key: key,
        child: GestureDetector(
          onTap: () => widget.onWordTap(word.start),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            decoration: BoxDecoration(
              color: i == widget.currentWordIndex ? widget.colorAudioTextBg : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(word.word, style: AppTextStyles.audioTextFontOnly(color: AppColors.colorWhite)),
          ),
        ),
      );

      final ctx = key.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox;
        final top = box.localToGlobal(Offset.zero).dy;

        if (currentLineTop == null || (top - currentLineTop).abs() < 1.0) {
          // same line
          currentLine.add(wordWidget);
          currentLineTop ??= top;
        } else {
          // new line starts, wrap previous line in background
          lineWidgets.add(_buildLineContainer(currentLine));
          currentLine = [wordWidget];
          currentLineTop = top;
        }
      } else {
        currentLine.add(wordWidget);
      }
    }

    if (currentLine.isNotEmpty) {
      lineWidgets.add(_buildLineContainer(currentLine));
    }

    return lineWidgets;
  }

  Widget _buildLineContainer(List<Widget> words) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: widget.paragraph.isBookmarked ?? false ? Colors.yellow.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Wrap(spacing: 3, runSpacing: 3, children: words),
    );
  }
}
