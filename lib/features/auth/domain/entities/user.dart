class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin' atau 'customer'
  final String? token;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'customer',
    this.token,
  });

  bool get isAdmin => role == 'admin';
}
