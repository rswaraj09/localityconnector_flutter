class User {
  final int? id;
  final String? username;
  final String? email;
  final String? password;
  final String? address;

  User({
    this.id,
    this.username,
    this.email,
    this.password,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username ?? '',
      'email': email ?? '',
      'password': password ?? '',
      'address': address ?? '',
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      address: map['address'] ?? '',
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      address: address ?? this.address,
    );
  }
} 