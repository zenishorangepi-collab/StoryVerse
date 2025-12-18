class BookmarkModel {
  final String paragraph;
  final String note;
  final String startTime;
  final String endTime;

  BookmarkModel({required this.paragraph, required this.note, required this.startTime, required this.endTime});

  Map<String, dynamic> toJson() => {'paragraph': paragraph, 'note': note, 'startTime': startTime, 'endTime': endTime};

  factory BookmarkModel.fromJson(Map<String, dynamic> json) =>
      BookmarkModel(paragraph: json['paragraph'], note: json['note'], startTime: json['startTime'], endTime: json['endTime']);
}
