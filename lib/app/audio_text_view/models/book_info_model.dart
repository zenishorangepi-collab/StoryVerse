class BookInfoModel {
  final String authorName;
  final String bookName;
  final String bookImage;
  final String bookId;

  BookInfoModel({required this.authorName, required this.bookName, required this.bookImage, required this.bookId});

  Map<String, dynamic> toMap() {
    return {"authorName": authorName, "bookName": bookName, "bookImage": bookImage, "bookId": bookId};
  }

  factory BookInfoModel.fromMap(Map<String, dynamic> map) {
    return BookInfoModel(authorName: map["authorName"] ?? "", bookName: map["bookName"] ?? "", bookImage: map["bookImage"] ?? "", bookId: map["bookId"] ?? "");
  }
}
