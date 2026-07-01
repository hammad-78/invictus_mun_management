import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class TeamMemberModel {
  final String memberId;
  final String name;
  final String department;
  final String post;
  final String contactNumber;
  final String email;
  final DateTime createdAt;

  const TeamMemberModel({
    required this.memberId,
    required this.name,
    required this.department,
    required this.post,
    required this.contactNumber,
    required this.email,
    required this.createdAt,
  });

  String get contact => contactNumber;

  TeamMemberModel copyWith({
    String? memberId,
    String? name,
    String? department,
    String? post,
    String? contactNumber,
    String? email,
    DateTime? createdAt,
  }) {
    return TeamMemberModel(
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      department: department ?? this.department,
      post: post ?? this.post,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'name': name,
      'department': department,
      'post': post,
      'contactNumber': contactNumber,
      'contact': contactNumber,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TeamMemberModel.fromMap(Map<String, dynamic> map) {
    return TeamMemberModel(
      memberId: (map['memberId'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      department: (map['department'] ?? '').toString(),
      post: (map['post'] ?? '').toString(),
      contactNumber: (map['contactNumber'] ?? map['contact'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      createdAt: _dateFromValue(map['createdAt']),
    );
  }

  String toJson() => jsonEncode(toMapForJson());

  factory TeamMemberModel.fromJson(String source) {
    return TeamMemberModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }

  Map<String, dynamic> toMapForJson() {
    return {
      ...toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static DateTime _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
