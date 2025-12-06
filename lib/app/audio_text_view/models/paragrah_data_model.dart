import 'package:flutter/cupertino.dart';
import 'word_data_model.dart';

class ParagraphData {
  final String id;
  final List<WordData> words;
  final List<GlobalKey> wordKeys;

  ParagraphData({required this.id, required this.words}) : wordKeys = List.generate(words.length, (_) => GlobalKey());

  factory ParagraphData.fromJson(Map<String, dynamic> json) {
    final wordsList = (json['words'] as List).map((w) => WordData.fromJson(w as Map<String, dynamic>)).toList();

    return ParagraphData(id: json['id'] as String, words: wordsList);
  }

  bool get isEmpty => words.isEmpty;
}
