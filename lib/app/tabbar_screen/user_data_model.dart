class UserModel {
  final String uid;
  final String email;
  final String name;
  final String photoUrl;

  UserModel({required this.uid, required this.email, required this.name, required this.photoUrl});

  // ✅ Add this method
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'name': name, 'photoUrl': photoUrl};
  }

  // 📌 Optional: Add fromJson for retrieving data later
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(uid: json['uid'] ?? '', email: json['email'] ?? '', name: json['name'] ?? '', photoUrl: json['photoUrl'] ?? '');
  }
}
