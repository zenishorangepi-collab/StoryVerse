import 'package:flutter/cupertino.dart';
import 'package:utsav_interview/app/audio_text_view/models/sentence_model.dart';
import 'package:utsav_interview/app/audio_text_view/models/word_data_model.dart';

class ParagraphData {
  final String id;
  final int start;
  final int end;
  final List<SentenceData> sentences;
  final List<GlobalKey> wordKeys;
  bool? isBookmarked;

  ParagraphData({required this.id, required this.start, required this.end, required this.sentences, this.isBookmarked = false})
    : wordKeys = List.generate(_countTotalWords(sentences), (_) => GlobalKey());

  // Helper to count total words across all sentences
  static int _countTotalWords(List<SentenceData> sentences) {
    return sentences.fold(0, (sum, sentence) => sum + sentence.words.length);
  }

  // Flatten all words
  List<WordData> get allWords => sentences.expand((sentence) => sentence.words).toList();

  factory ParagraphData.fromJson(Map<String, dynamic> json) {
    try {
      final sentencesList = (json['sentences'] as List?)?.map((s) => SentenceData.fromJson(s as Map<String, dynamic>)).where((s) => !s.isEmpty).toList() ?? [];

      return ParagraphData(
        id: json['id'] as String,
        start: json['start'] as int,
        end: json['end'] as int,
        sentences: sentencesList,
        isBookmarked: json['isBookmarked'] as bool? ?? false,
      );
    } catch (e) {
      throw FormatException('Invalid paragraph data: $e');
    }
  }

  /// ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {'id': id, 'start': start, 'end': end, 'sentences': sentences.map((s) => s?.toJson()).toList(), 'isBookmarked': isBookmarked};
  }

  bool get isEmpty => sentences.isEmpty || allWords.isEmpty;
}
