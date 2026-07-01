import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String attendanceId;
  final String personId;
  final String personType;
  final DateTime date;
  final int day;
  final bool present;

  const AttendanceModel({
    required this.attendanceId,
    required this.personId,
    required this.personType,
    required this.date,
    required this.day,
    required this.present,
  });

  AttendanceModel copyWith({
    String? attendanceId,
    String? personId,
    String? personType,
    DateTime? date,
    int? day,
    bool? present,
  }) {
    return AttendanceModel(
      attendanceId: attendanceId ?? this.attendanceId,
      personId: personId ?? this.personId,
      personType: personType ?? this.personType,
      date: date ?? this.date,
      day: day ?? this.day,
      present: present ?? this.present,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'attendanceId': attendanceId,
      'personId': personId,
      'personType': personType,
      'date': Timestamp.fromDate(date),
      'day': day,
      'present': present,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      attendanceId: (map['attendanceId'] ?? '').toString(),
      personId: (map['personId'] ?? '').toString(),
      personType: (map['personType'] ?? '').toString(),
      date: _dateFromValue(map['date']),
      day: _intFromValue(map['day'], fallback: 1),
      present: map['present'] == true,
    );
  }

  String toJson() => jsonEncode(toMapForJson());

  factory AttendanceModel.fromJson(String source) {
    return AttendanceModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }

  Map<String, dynamic> toMapForJson() {
    return {
      ...toMap(),
      'date': date.toIso8601String(),
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

  static int _intFromValue(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
