// lib/app/collections/models/collection_model.dart

class CollectionModel {
  final String id;
  final String name;
  final String iconType;
  final DateTime createdAt;
  final List<String> bookIds; // Store book IDs in this collection

  CollectionModel({required this.id, required this.name, required this.iconType, required this.createdAt, this.bookIds = const []});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'iconType': iconType, 'createdAt': createdAt.toIso8601String(), 'bookIds': bookIds};
  }

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconType: json['iconType'] ?? 'folder',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      bookIds: List<String>.from(json['bookIds'] ?? []),
    );
  }

  CollectionModel copyWith({String? id, String? name, String? iconType, DateTime? createdAt, List<String>? bookIds}) {
    return CollectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconType: iconType ?? this.iconType,
      createdAt: createdAt ?? this.createdAt,
      bookIds: bookIds ?? this.bookIds,
    );
  }
}
