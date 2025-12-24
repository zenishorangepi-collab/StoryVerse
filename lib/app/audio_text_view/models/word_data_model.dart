class WordData {
  final String word;
  final int start;
  final int end;

  const WordData({required this.word, required this.start, required this.end});

  factory WordData.fromJson(Map<String, dynamic> json) {
    try {
      final start = json['start'] as int;
      final end = json['end'] as int;

      if (start < 0 || end < start) {
        throw FormatException('Invalid timestamp: start=$start, end=$end');
      }

      return WordData(word: (json['word'] as String).trim(), start: start, end: end);
    } catch (e) {
      throw FormatException('Invalid word data: $e');
    }
  }

  /// ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {'word': word, 'start': start, 'end': end};
  }

  bool containsTime(int timeMs) => timeMs >= start && timeMs < end;
}
