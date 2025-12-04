

import 'word_data_model.dart';

class ParagraphData {
  final String id;
  final List<WordData> words;

  const ParagraphData({required this.id, required this.words});

  factory ParagraphData.fromJson(Map<String, dynamic> json) {
    try {
      return ParagraphData(
        id: json['id'] as String,
        words: (json['words'] as List)
            .map((w) => WordData.fromJson(w as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw FormatException('Invalid paragraph data: $e');
    }
  }

  bool get isEmpty => words.isEmpty;
}
