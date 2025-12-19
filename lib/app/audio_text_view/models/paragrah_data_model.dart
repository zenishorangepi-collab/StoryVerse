import 'package:flutter/cupertino.dart';
import 'package:utsav_interview/app/audio_text_view/models/sentence_model.dart';
import 'word_data_model.dart';

class ParagraphData {
  final String id;
  final int start;
  final int end;
  final String? text;
  final List<SentenceData> sentences;
  final List<GlobalKey> wordKeys;
  bool? isBookmarked;

  ParagraphData({required this.id, required this.start, required this.end, this.text, required this.sentences, this.isBookmarked = false})
    : wordKeys = List.generate(_countTotalWords(sentences), (_) => GlobalKey());

  // Helper to count total words across all sentences
  static int _countTotalWords(List<SentenceData> sentences) {
    return sentences.fold(0, (sum, sentence) => sum + sentence.words.length);
  }

  // Helper to get all words from all sentences (flattened)
  List<WordData> get allWords {
    return sentences.expand((sentence) => sentence.words).toList();
  }

  factory ParagraphData.fromJson(Map<String, dynamic> json) {
    try {
      final sentencesList = (json['sentences'] as List?)?.map((s) => SentenceData.fromJson(s as Map<String, dynamic>)).where((s) => !s.isEmpty).toList() ?? [];

      return ParagraphData(
        id: json['id'] as String,
        start: json['start'] as int,
        end: json['end'] as int,
        text: json['text'] as String?,
        sentences: sentencesList,
      );
    } catch (e) {
      throw FormatException('Invalid paragraph data: $e');
    }
  }

  bool get isEmpty => sentences.isEmpty || allWords.isEmpty;
}
