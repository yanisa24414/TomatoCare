class User {
  final int? id;
  final String email;
  final String password;
  final String username;
  final DateTime createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.username,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'username': username,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      username: map['username'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
