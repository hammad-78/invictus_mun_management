import 'dart:async';

import 'package:flutter/material.dart';

import '../models/team_member_model.dart';
import '../repositories/team_repository.dart';

class TeamViewModel extends ChangeNotifier {
  final TeamRepository _repository;

  TeamViewModel({TeamRepository? repository})
      : _repository = repository ?? TeamRepository();

  StreamSubscription<List<TeamMemberModel>>? _subscription;
  List<TeamMemberModel> _members = [];
  List<TeamMemberModel> members = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  void startListening() {
    if (_subscription != null) return;
    errorMessage = null;
    _subscription = _repository.streamMembers().listen((items) {
      _members = items;
      _applySearch();
    }, onError: (Object error) {
      errorMessage = error.toString();
      notifyListeners();
    });
  }

  Future<void> stopListening() async {
    final hadState = _subscription != null ||
        _members.isNotEmpty ||
        members.isNotEmpty ||
        errorMessage != null ||
        searchQuery.isNotEmpty;
    await _subscription?.cancel();
    _subscription = null;
    _members = [];
    members = [];
    errorMessage = null;
    searchQuery = '';
    if (hadState) notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    _applySearch();
  }

  Future<void> addMember(TeamMemberModel member) async {
    await _run(() => _repository.addMember(member));
  }

  Future<void> updateMember(TeamMemberModel member) async {
    await _run(() => _repository.updateMember(member));
  }

  Future<void> deleteMember(String memberId) async {
    await _run(() => _repository.deleteMember(memberId));
  }

  void _applySearch() {
    final query = searchQuery.trim().toLowerCase();
    members = query.isEmpty
        ? List.of(_members)
        : _members.where((member) {
            return member.name.toLowerCase().contains(query) ||
                member.memberId.toLowerCase().contains(query);
          }).toList();
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      await action();
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
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
}
