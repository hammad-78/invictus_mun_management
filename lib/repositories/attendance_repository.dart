import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_model.dart';

class AttendanceRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final String collection =
      "attendance";

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(collection);

  Future<void> markAttendance(AttendanceModel attendance) async {
    await _firestore
        .collection(collection)
        .doc(attendance.attendanceId)
        .set(attendance.toMap());
  }

  Future<bool> alreadyMarked(
    String personId,
    int day,
    String personType,
  ) async {
    final snapshot = await _firestore
        .collection(collection)
        .where(
      "personId",
      isEqualTo: personId,
    )
        .where(
      "personType",
      isEqualTo: personType,
    )
        .where(
      "day",
      isEqualTo: day,
    )
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<List<AttendanceModel>> getAttendanceByDate(DateTime date) async {
    final snapshot = await _firestore
        .collection(collection)
        .where(
      "date",
      isEqualTo: date
          .toIso8601String(),
    )
        .get();

    return snapshot.docs
        .map(
          (e) =>
          AttendanceModel.fromMap(
              e.data()),
    )
        .toList();
  }

  Future<List<AttendanceModel>> getAttendanceByDay({
    required int day,
    String? personType,
  }) async {
    Query<Map<String, dynamic>> query = _ref.where('day', isEqualTo: day);
    if (personType != null) {
      query = query.where('personType', isEqualTo: personType);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => AttendanceModel.fromMap(doc.data()))
        .toList();
  }

  Stream<List<AttendanceModel>> streamAttendance() {
    return _ref.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> deleteAttendance(String attendanceId) {
    return _ref.doc(attendanceId).delete();
  }
}
