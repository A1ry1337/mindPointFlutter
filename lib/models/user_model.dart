class UserModel {
  final String accessToken;
  final String userId;
  final String username;
  final String fullname;
  final String email;
  final bool isManager;

  UserModel({
    required this.accessToken,
    required this.userId,
    required this.username,
    required this.fullname,
    required this.email,
    required this.isManager,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accessToken: json['access'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      fullname: json['fullname'] ?? '',
      email: json['email'] ?? '',
      isManager: json['is_manager'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'userId': userId,
      'username': username,
      'fullname': fullname,
      'email': email,
      'is_manager': isManager,
    };
  }
}