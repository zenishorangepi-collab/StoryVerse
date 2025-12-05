import 'package:utsav_interview/app/audio_text_view/models/paragrah_data_model.dart';

class TranscriptData {
  final List<ParagraphData> paragraphs;
  final String? audioUrl;
  final int? totalWords;
  final int? duration;
  final String language;

  const TranscriptData({this.paragraphs = const [], this.audioUrl, this.totalWords, this.duration, this.language = 'en-US'});

  factory TranscriptData.fromJson(Map<String, dynamic> json) {
    try {
      final paragraphs = (json['paragraphs'] as List).map((p) => ParagraphData.fromJson(p as Map<String, dynamic>)).where((p) => !p.isEmpty).toList();

      if (paragraphs.isEmpty) {
        throw FormatException('No valid paragraphs found');
      }

      return TranscriptData(
        paragraphs: paragraphs,
        audioUrl: json['audioUrl'] as String,
        totalWords: json['metadata']['totalWords'] as int,
        duration: json['metadata']['duration'] as int,
        language: json['metadata']['language'] as String? ?? 'en-US',
      );
    } catch (e) {
      throw FormatException('Invalid transcript data: $e');
    }
  }
}
