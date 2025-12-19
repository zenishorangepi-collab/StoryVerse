import 'word_data_model.dart';

class SentenceData {
  final String id;
  final int start;
  final int end;
  final String text;
  final List<WordData> words;

  SentenceData({required this.id, required this.start, required this.end, required this.text, required this.words});

  factory SentenceData.fromJson(Map<String, dynamic> json) {
    try {
      final wordsList = (json['words'] as List?)?.map((w) => WordData.fromJson(w as Map<String, dynamic>)).toList() ?? [];

      return SentenceData(id: json['id'] as String, start: json['start'] as int, end: json['end'] as int, text: json['text'] as String, words: wordsList);
    } catch (e) {
      throw FormatException('Invalid sentence data: $e');
    }
  }

  bool get isEmpty => words.isEmpty;
}
