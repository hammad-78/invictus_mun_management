import 'dart:async';

import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';

class AttendanceViewModel extends ChangeNotifier {
  final AttendanceRepository _repository;

  AttendanceViewModel({AttendanceRepository? repository})
      : _repository = repository ?? AttendanceRepository();

  StreamSubscription<List<AttendanceModel>>? _subscription;
  List<AttendanceModel> attendance = [];
  bool isLoading = false;
  String? errorMessage;

  void startListening() {
    if (_subscription != null) return;
    errorMessage = null;
    _subscription = _repository.streamAttendance().listen((items) {
      attendance = items;
      notifyListeners();
    }, onError: (Object error) {
      errorMessage = error.toString();
      notifyListeners();
    });
  }

  Future<void> stopListening() async {
    final hadState =
        _subscription != null || attendance.isNotEmpty || errorMessage != null;
    await _subscription?.cancel();
    _subscription = null;
    attendance = [];
    errorMessage = null;
    if (hadState) notifyListeners();
  }

  int countFor(String personType, {int? day}) {
    return attendance
        .where(
          (item) =>
              item.personType == personType &&
              item.present &&
              (day == null || item.day == day),
        )
        .length;
  }

  AttendanceModel? recordFor(String personId, String personType, int day) {
    for (final item in attendance) {
      if (item.personId == personId &&
          item.personType == personType &&
          item.day == day) {
        return item;
      }
    }
    return null;
  }

  bool isMarked(String personId, String personType, int day) {
    return recordFor(personId, personType, day) != null;
  }

  bool isPresent(String personId, String personType, int day) {
    return attendance.any(
      (item) =>
          item.personId == personId &&
          item.personType == personType &&
          item.day == day &&
          item.present,
    );
  }

  Future<bool> setAttendance({
    required String personId,
    required String personType,
    required int day,
    required bool present,
  }) async {
    final attendanceId = '$personType-$personId-day$day';
    final model = AttendanceModel(
      attendanceId: attendanceId,
      personId: personId,
      personType: personType,
      date: DateTime.now(),
      day: day,
      present: present,
    );

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      await _repository.markAttendance(model);
      _upsertLocalRecord(model);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAttendance({
    required String personId,
    required String personType,
    required int day,
    bool present = true,
  }) {
    return setAttendance(
      personId: personId,
      personType: personType,
      day: day,
      present: present,
    );
  }

  Future<bool> clearAttendance({
    required String personId,
    required String personType,
    required int day,
  }) async {
    final attendanceId = '$personType-$personId-day$day';

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      await _repository.deleteAttendance(attendanceId);
      attendance = attendance
          .where((item) => item.attendanceId != attendanceId)
          .toList();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _upsertLocalRecord(AttendanceModel model) {
    final index = attendance.indexWhere(
      (item) => item.attendanceId == model.attendanceId,
    );
    if (index == -1) {
      attendance = [...attendance, model];
      return;
    }

    attendance = [
      ...attendance.take(index),
      model,
      ...attendance.skip(index + 1),
    ];
  }
}
