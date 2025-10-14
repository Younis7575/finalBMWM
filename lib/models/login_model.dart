class LoginModel {
  final String status;
  final String message;
  final String token;
  final User user;

  LoginModel({
    required this.status,
    required this.message,
    required this.token,
    required this.user,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json['status'],
      message: json['message'],
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final String id;
  final String username;
  final String fullName;
  final String profilePicture;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      profilePicture: json['profile_picture'],
    );
  }
}
