import 'dart:async';

import 'package:flutter/material.dart';

import '../models/delegate_model.dart';
import '../repositories/delegate_repository.dart';

class DelegateViewModel extends ChangeNotifier {
  final DelegateRepository _repository;

  DelegateViewModel({DelegateRepository? repository})
      : _repository = repository ?? DelegateRepository();

  StreamSubscription<List<DelegateModel>>? _subscription;
  List<DelegateModel> _delegates = [];
  List<DelegateModel> delegates = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  void startListening() {
    if (_subscription != null) return;
    errorMessage = null;
    _subscription = _repository.streamDelegates().listen((items) {
      _delegates = items;
      _applySearch();
    }, onError: (Object error) {
      errorMessage = error.toString();
      notifyListeners();
    });
  }

  Future<void> stopListening() async {
    final hadState = _subscription != null ||
        _delegates.isNotEmpty ||
        delegates.isNotEmpty ||
        errorMessage != null ||
        searchQuery.isNotEmpty;
    await _subscription?.cancel();
    _subscription = null;
    _delegates = [];
    delegates = [];
    errorMessage = null;
    searchQuery = '';
    if (hadState) notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    _applySearch();
  }

  Future<void> addDelegate(DelegateModel delegate) async {
    await _run(() => _repository.addDelegate(delegate));
  }

  Future<void> updateDelegate(DelegateModel delegate) async {
    await _run(() => _repository.updateDelegate(delegate));
  }

  Future<void> deleteDelegate(String delegateId) async {
    await _run(() => _repository.deleteDelegate(delegateId));
  }

  void _applySearch() {
    final query = searchQuery.trim().toLowerCase();
    delegates = query.isEmpty
        ? List.of(_delegates)
        : _delegates.where((delegate) {
            return delegate.name.toLowerCase().contains(query) ||
                delegate.cnic.toLowerCase().contains(query) ||
                delegate.delegateId.toLowerCase().contains(query);
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
