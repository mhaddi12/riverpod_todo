enum UserRole { manager, employee }

class AppUser {
  final String uid;
  final String email;
  final UserRole role;

  AppUser({required this.uid, required this.email, required this.role});

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'role': role.name,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'],
    email: json['email'],
    role: UserRole.values.firstWhere(
      (e) => e.name == json['role'],
      orElse: () => UserRole.employee,
    ),
  );
}
