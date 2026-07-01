import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class DelegateModel {
  final String delegateId;
  final String cnic;
  final String name;
  final String contactNumber;
  final DateTime dateOfBirth;
  final String committee;
  final String registrationType;
  final String paymentMethod;
  final String paymentStatus;
  final double amountPaid;
  final String remarks;
  final DateTime createdAt;

  const DelegateModel({
    required this.delegateId,
    required this.cnic,
    required this.name,
    required this.contactNumber,
    required this.dateOfBirth,
    required this.committee,
    required this.registrationType,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amountPaid,
    required this.remarks,
    required this.createdAt,
  });

  String get id => delegateId;
  String get contact => contactNumber;

  DelegateModel copyWith({
    String? delegateId,
    String? cnic,
    String? name,
    String? contactNumber,
    DateTime? dateOfBirth,
    String? committee,
    String? registrationType,
    String? paymentMethod,
    String? paymentStatus,
    double? amountPaid,
    String? remarks,
    DateTime? createdAt,
  }) {
    return DelegateModel(
      delegateId: delegateId ?? this.delegateId,
      cnic: cnic ?? this.cnic,
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      committee: committee ?? this.committee,
      registrationType: registrationType ?? this.registrationType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'delegateId': delegateId,
      'id': delegateId,
      'cnic': cnic,
      'name': name,
      'contactNumber': contactNumber,
      'contact': contactNumber,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'committee': committee,
      'registrationType': registrationType,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'amountPaid': amountPaid,
      'remarks': remarks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory DelegateModel.fromMap(Map<String, dynamic> map) {
    return DelegateModel(
      delegateId: (map['delegateId'] ?? map['id'] ?? '').toString(),
      cnic: (map['cnic'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      contactNumber: (map['contactNumber'] ?? map['contact'] ?? '').toString(),
      dateOfBirth: _dateFromValue(map['dateOfBirth']),
      committee: (map['committee'] ?? '').toString(),
      registrationType: (map['registrationType'] ?? 'Delegate').toString(),
      paymentMethod: (map['paymentMethod'] ?? 'Cash').toString(),
      paymentStatus: (map['paymentStatus'] ?? 'Pending').toString(),
      amountPaid: _doubleFromValue(map['amountPaid']),
      remarks: (map['remarks'] ?? '').toString(),
      createdAt: _dateFromValue(map['createdAt']),
    );
  }

  String toJson() => jsonEncode(toMapForJson());

  factory DelegateModel.fromJson(String source) {
    return DelegateModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }

  Map<String, dynamic> toMapForJson() {
    return {
      ...toMap(),
      'dateOfBirth': dateOfBirth.toIso8601String(),
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

  static double _doubleFromValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
