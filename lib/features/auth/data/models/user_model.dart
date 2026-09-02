class UserModel {
  final String email;
  final String? token;
  final String? refreshToken;

  /// Present on `/auth/register`'s response; absent on `/auth/login`'s,
  /// which returns only the token pair — see `AuthRepository.login`, which
  /// separately calls `GET /api/users/me` to resolve this for existing
  /// users/other devices.
  final String? username;

  UserModel({required this.email, this.token, this.refreshToken, this.username});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      token: json['accessToken'] ?? json['token'],
      refreshToken: json['refreshToken'],
      username: json['username'],
    );
  }
}
