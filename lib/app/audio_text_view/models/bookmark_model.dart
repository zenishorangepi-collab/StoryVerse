class BookmarkModel {
  String id; // paragraphId
  String bookId;
  String chapterId;
  int chapterIndex;
  String chapterTitle;
  String paragraph;
  String note;
  String startTime;
  String endTime;

  BookmarkModel({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.chapterIndex,
    required this.chapterTitle,
    required this.paragraph,
    required this.note,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'chapterId': chapterId,
    'chapterIndex': chapterIndex,
    'chapterTitle': chapterTitle,
    'paragraph': paragraph,
    'note': note,
    'startTime': startTime,
    'endTime': endTime,
  };

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'],
      bookId: json['bookId'],
      chapterId: json['chapterId'],
      chapterIndex: json['chapterIndex'],
      chapterTitle: json['chapterTitle'],
      paragraph: json['paragraph'],
      note: json['note'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}
