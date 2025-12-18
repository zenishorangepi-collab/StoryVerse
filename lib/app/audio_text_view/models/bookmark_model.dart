class BookmarkModel {
  String paragraph;
  String note;
  String startTime;
  String endTime;
  String id;

  BookmarkModel({required this.paragraph, required this.note, required this.startTime, required this.endTime, required this.id});

  Map<String, dynamic> toJson() => {'paragraph': paragraph, 'note': note, 'startTime': startTime, 'endTime': endTime, 'id': id};

  factory BookmarkModel.fromJson(Map<String, dynamic> json) =>
      BookmarkModel(paragraph: json['paragraph'], note: json['note'], startTime: json['startTime'], endTime: json['endTime'], id: json['id']);
}
