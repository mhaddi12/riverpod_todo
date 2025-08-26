enum UserRole { manager, employee }

class AppUser {
  final String uid;
  final String email;
  final UserRole role;
  final String name;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'role': role.name,
    'name': name,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'],
    email: json['email'],
    role: UserRole.values.firstWhere(
      (e) => e.name == json['role'],
      orElse: () => UserRole.employee,
    ),
    name: json['name'],
  );
}
