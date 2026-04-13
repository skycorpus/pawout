class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }
}
