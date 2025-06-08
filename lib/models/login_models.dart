// ==== Model Login ====

class Login {
  final String token;
  final User user;

  Login({required this.token, required this.user});

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      token: json['data']['token'],
      user: User.fromJson(json['data']['user']),
    );
  }
}

class User {
  final int id;
  final String email;
  final String name;

  User({required this.id, required this.email, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }
}