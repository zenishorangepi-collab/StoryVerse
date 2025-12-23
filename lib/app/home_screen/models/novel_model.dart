class NovelsDataModel {
  List<AudioFiles>? audioFiles;
  String? id;
  Author? author;
  String? bookCoverUrl;
  String? bookName;
  List<Categories>? categories;
  int? createdAt;
  Author? language;
  String? publishedDate;
  String? summary;
  int? updatedAt;
  double? totalAudioLength;

  NovelsDataModel({
    this.audioFiles,
    this.id,
    this.author,
    this.bookCoverUrl,
    this.bookName,
    this.categories,
    this.createdAt,
    this.language,
    this.publishedDate,
    this.summary,
    this.updatedAt,
    this.totalAudioLength,
  });

  NovelsDataModel.fromJson(Map<String, dynamic> json) {
    if (json['audioFiles'] != null) {
      audioFiles = <AudioFiles>[];
      json['audioFiles'].forEach((v) {
        audioFiles!.add(AudioFiles.fromJson(v));
      });
    }
    id = json['id'];
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
    bookCoverUrl = json['bookCoverUrl'];
    bookName = json['bookName'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    language = json['language'] != null ? Author.fromJson(json['language']) : null;
    publishedDate = json['publishedDate'];
    summary = json['summary'];
    updatedAt = json['updatedAt'];
    totalAudioLength = json['totalAudioLength'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (audioFiles != null) {
      data['audioFiles'] = audioFiles!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    data['bookCoverUrl'] = bookCoverUrl;
    data['bookName'] = bookName;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    if (language != null) {
      data['language'] = language!.toJson();
    }
    data['publishedDate'] = publishedDate;
    data['summary'] = summary;
    data['updatedAt'] = updatedAt;
    data['totalAudioLength'] = totalAudioLength;
    return data;
  }
}

class AudioFiles {
  String? id;
  String? name;
  String? url;
  String? audioJsonUrl;
  double? duration;

  AudioFiles({this.id, this.name, this.url, this.audioJsonUrl, this.duration});

  AudioFiles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    url = json['url'];
    audioJsonUrl = json['audioJsonUrl'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['url'] = url;
    data['audioJsonUrl'] = audioJsonUrl;
    data['duration'] = duration;
    return data;
  }
}

class Author {
  String? id;
  String? name;

  Author({this.id, this.name});

  Author.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Categories {
  String? id;
  String? name;

  Categories({this.id, this.name});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
