class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin' atau 'customer'
  final String? token;
  final String? photoUrl;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'customer',
    this.token,
    this.photoUrl,
  });

  bool get isAdmin => role == 'admin';
}
