class BookmarkModel {
  String paragraph;
  String note;
  String startTime;
  String endTime;
  String id;
  String chapterId;
  int chapterIndex;
  String chapterTitle;

  BookmarkModel({
    required this.paragraph,
    required this.note,
    required this.startTime,
    required this.endTime,
    required this.id,
    required this.chapterId,
    required this.chapterIndex,
    required this.chapterTitle,
  });

  Map<String, dynamic> toJson() => {
    'paragraph': paragraph,
    'note': note,
    'startTime': startTime,
    'endTime': endTime,
    'id': id,
    "chapterId": chapterId,
    "chapterIndex": chapterIndex,
    "chapterTitle": chapterTitle,
  };

  factory BookmarkModel.fromJson(Map<String, dynamic> json) => BookmarkModel(
    paragraph: json['paragraph'],
    note: json['note'],
    startTime: json['startTime'],
    endTime: json['endTime'],
    id: json['id'],
    chapterId: json['chapterId'],
    chapterIndex: json['chapterIndex'],
    chapterTitle: json['chapterTitle'],
  );
}
