class UserModel {
  final String uid;
  final String email;
  final String name;
  final String photoUrl;

  const UserModel({required this.uid, required this.email, required this.name, required this.photoUrl});

  /// Convert model → Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'name': name, 'photoUrl': photoUrl};
  }

  /// Convert Map → model (from Firebase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(uid: map['uid'] ?? '', email: map['email'] ?? '', name: map['name'] ?? '', photoUrl: map['photoUrl'] ?? '');
  }

  /// Create model directly from Firebase User
  factory UserModel.fromFirebaseUser({required String uid, String? email, String? name, String? photoUrl}) {
    return UserModel(uid: uid, email: email ?? '', name: name ?? '', photoUrl: photoUrl ?? '');
  }
}
