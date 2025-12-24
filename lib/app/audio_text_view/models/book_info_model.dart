class BookInfoModel {
  final String authorName;
  final String bookName;
  final String bookImage;
  final String bookId;
  final String textUrl;
  final String audioUrl;
  final String summary;

  BookInfoModel({
    required this.authorName,
    required this.bookName,
    required this.bookImage,
    required this.bookId,
    required this.textUrl,
    required this.audioUrl,
    required this.summary,
  });

  Map<String, dynamic> toMap() {
    return {
      "authorName": authorName,
      "bookName": bookName,
      "bookImage": bookImage,
      "bookId": bookId,
      "textUrl": textUrl,
      "audioUrl": audioUrl,
      "summary": summary,
    };
  }

  factory BookInfoModel.fromMap(Map<String, dynamic> map) {
    return BookInfoModel(
      authorName: map["authorName"] ?? "",
      bookName: map["bookName"] ?? "",
      bookImage: map["bookImage"] ?? "",
      bookId: map["bookId"] ?? "",
      textUrl: map["textUrl"] ?? "",
      audioUrl: map["audioUrl"] ?? "",
      summary: map["summary"] ?? "",
    );
  }
}
