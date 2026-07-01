import 'dart:async';

import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../models/delegate_model.dart';
import '../models/team_member_model.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/delegate_repository.dart';
import '../repositories/team_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    DelegateRepository? delegateRepository,
    TeamRepository? teamRepository,
    AttendanceRepository? attendanceRepository,
  })  : _delegateRepository = delegateRepository ?? DelegateRepository(),
        _teamRepository = teamRepository ?? TeamRepository(),
        _attendanceRepository = attendanceRepository ?? AttendanceRepository();

  final DelegateRepository _delegateRepository;
  final TeamRepository _teamRepository;
  final AttendanceRepository _attendanceRepository;

  StreamSubscription<List<DelegateModel>>? _delegateSubscription;
  StreamSubscription<List<TeamMemberModel>>? _teamSubscription;
  StreamSubscription<List<AttendanceModel>>? _attendanceSubscription;

  List<DelegateModel> _delegates = [];
  List<TeamMemberModel> _teamMembers = [];
  List<AttendanceModel> _attendance = [];

  int totalDelegates = 0;
  int totalTeamMembers = 0;
  int paidDelegates = 0;
  int pendingDelegates = 0;
  int delegateAttendanceCount = 0;
  int teamAttendanceCount = 0;
  String? errorMessage;

  void startListening() {
    if (_delegateSubscription != null ||
        _teamSubscription != null ||
        _attendanceSubscription != null) {
      return;
    }
    errorMessage = null;
    _delegateSubscription = _delegateRepository.streamDelegates().listen(
      (delegates) {
        _delegates = delegates;
        _recalculate();
      },
      onError: _setError,
    );

    _teamSubscription = _teamRepository.streamMembers().listen(
      (members) {
        _teamMembers = members;
        _recalculate();
      },
      onError: _setError,
    );

    _attendanceSubscription = _attendanceRepository.streamAttendance().listen(
      (attendance) {
        _attendance = attendance;
        _recalculate();
      },
      onError: _setError,
    );
  }

  Future<void> stopListening() async {
    final hadState = _delegateSubscription != null ||
        _teamSubscription != null ||
        _attendanceSubscription != null ||
        _delegates.isNotEmpty ||
        _teamMembers.isNotEmpty ||
        _attendance.isNotEmpty ||
        totalDelegates != 0 ||
        totalTeamMembers != 0 ||
        paidDelegates != 0 ||
        pendingDelegates != 0 ||
        delegateAttendanceCount != 0 ||
        teamAttendanceCount != 0 ||
        errorMessage != null;
    await _delegateSubscription?.cancel();
    await _teamSubscription?.cancel();
    await _attendanceSubscription?.cancel();
    _delegateSubscription = null;
    _teamSubscription = null;
    _attendanceSubscription = null;
    _delegates = [];
    _teamMembers = [];
    _attendance = [];
    totalDelegates = 0;
    totalTeamMembers = 0;
    paidDelegates = 0;
    pendingDelegates = 0;
    delegateAttendanceCount = 0;
    teamAttendanceCount = 0;
    errorMessage = null;
    if (hadState) notifyListeners();
  }

  void _recalculate() {
    final delegateIds = _delegates.map((delegate) => delegate.delegateId).toSet();
    final teamMemberIds =
        _teamMembers.map((member) => member.memberId).toSet();

    final presentDelegateIds = _attendance
        .where(
          (item) =>
              item.personType == 'delegate' &&
              item.present &&
              delegateIds.contains(item.personId),
        )
        .map((item) => item.personId)
        .toSet();

    final presentTeamMemberIds = _attendance
        .where(
          (item) =>
              item.personType == 'team' &&
              item.present &&
              teamMemberIds.contains(item.personId),
        )
        .map((item) => item.personId)
        .toSet();

    totalDelegates = _delegates.length;
    totalTeamMembers = _teamMembers.length;
    paidDelegates = _delegates
        .where((item) => item.paymentStatus.toLowerCase() == 'paid')
        .length;
    pendingDelegates = _delegates
        .where((item) => item.paymentStatus.toLowerCase() == 'pending')
        .length;
    delegateAttendanceCount = presentDelegateIds.length;
    teamAttendanceCount = presentTeamMemberIds.length;

    notifyListeners();
  }

  void _setError(Object error) {
    errorMessage = error.toString();
    notifyListeners();
  }

  @override
  void dispose() {
    _delegateSubscription?.cancel();
    _teamSubscription?.cancel();
    _attendanceSubscription?.cancel();
    super.dispose();
  }
}
