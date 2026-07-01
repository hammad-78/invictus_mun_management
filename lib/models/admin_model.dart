import 'dart:convert';

class AdminModel {
  final String uid;
  final String email;
  final String role;

  const AdminModel({
    required this.uid,
    required this.email,
    required this.role,
  });

  AdminModel copyWith({
    String? uid,
    String? email,
    String? role,
  }) {
    return AdminModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      uid: (map['uid'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      role: (map['role'] ?? 'admin').toString(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory AdminModel.fromJson(String source) {
    return AdminModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}
