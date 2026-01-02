// lib/app/downloads/models/download_model.dart

class DownloadModel {
  final String id;
  final String novelId;
  final String bookName;
  final String authorName;
  final String coverUrl;
  final String summary;
  final double totalAudioLength;
  final DateTime downloadedAt;
  final List<DownloadedChapter> chapters;
  final int totalSize; // in bytes

  DownloadModel({
    required this.id,
    required this.novelId,
    required this.bookName,
    required this.authorName,
    required this.coverUrl,
    required this.summary,
    required this.totalAudioLength,
    required this.downloadedAt,
    required this.chapters,
    required this.totalSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novelId': novelId,
      'bookName': bookName,
      'authorName': authorName,
      'coverUrl': coverUrl,
      'summary': summary,
      'totalAudioLength': totalAudioLength,
      'downloadedAt': downloadedAt.toIso8601String(),
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'totalSize': totalSize,
    };
  }

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      id: json['id'] ?? '',
      novelId: json['novelId'] ?? '',
      bookName: json['bookName'] ?? '',
      authorName: json['authorName'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      summary: json['summary'] ?? '',
      totalAudioLength: (json['totalAudioLength'] ?? 0.0).toDouble(),
      downloadedAt: DateTime.parse(json['downloadedAt'] ?? DateTime.now().toIso8601String()),
      chapters: (json['chapters'] as List?)?.map((c) => DownloadedChapter.fromJson(c)).toList() ?? [],
      totalSize: json['totalSize'] ?? 0,
    );
  }
}

class DownloadedChapter {
  final String chapterId;
  final String chapterName;
  final String audioLocalPath;
  final String textLocalPath;
  final int chapterIndex;
  final int size;

  DownloadedChapter({
    required this.chapterId,
    required this.chapterName,
    required this.audioLocalPath,
    required this.textLocalPath,
    required this.chapterIndex,
    required this.size,
  });

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'chapterName': chapterName,
      'audioLocalPath': audioLocalPath,
      'textLocalPath': textLocalPath,
      'chapterIndex': chapterIndex,
      'size': size,
    };
  }

  factory DownloadedChapter.fromJson(Map<String, dynamic> json) {
    return DownloadedChapter(
      chapterId: json['chapterId'] ?? '',
      chapterName: json['chapterName'] ?? '',
      audioLocalPath: json['audioLocalPath'] ?? '',
      textLocalPath: json['textLocalPath'] ?? '',
      chapterIndex: json['chapterIndex'] ?? 0,
      size: json['size'] ?? 0,
    );
  }
}
