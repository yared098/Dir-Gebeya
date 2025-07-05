class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}
