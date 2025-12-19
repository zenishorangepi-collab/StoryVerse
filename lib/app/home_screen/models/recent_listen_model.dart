class RecentViewModel {
  final String id;
  final String title;
  final String image;
  final String summary;
  final String length;

  RecentViewModel({required this.id, required this.title, required this.image, required this.summary, required this.length});

  Map<String, dynamic> toJson() => {"id": id, "title": title, "image": image, "summary": summary, "length": length};

  factory RecentViewModel.fromJson(Map<String, dynamic> json) =>
      RecentViewModel(id: json["id"], title: json["title"], image: json["image"], summary: json["summary"], length: json["length"]);
}
