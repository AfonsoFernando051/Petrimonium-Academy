class UserModel {
  final String email;
  final String? token;
  final String? refreshToken;

  UserModel({required this.email, this.token, this.refreshToken});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      token: json['accessToken'] ?? json['token'],
      refreshToken: json['refreshToken'],
    );
  }
}
