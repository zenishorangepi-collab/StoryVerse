class CategoriesDataModel {
  int? createdAt;
  String? description;
  String? name;
  String? id;
  int? updatedAt;

  CategoriesDataModel({this.createdAt, this.description, this.name, this.id, this.updatedAt});

  CategoriesDataModel.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    description = json['description'];
    name = json['name'];
    id = json['id'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['description'] = description;
    data['name'] = name;
    data['id'] = id;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
