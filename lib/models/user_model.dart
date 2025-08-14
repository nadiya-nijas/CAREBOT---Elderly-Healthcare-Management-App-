class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': DateTime.now(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      
      role: map['role'],
    );
  }

  get displayName => null;
}
