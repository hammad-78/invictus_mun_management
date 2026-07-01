import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/delegate_model.dart';

class DelegateRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = "delegates";
  final String _teamMembersCollection = "team_members";

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(collection);

  Future<void> addDelegate(DelegateModel delegate) async {
    final delegateId = delegate.delegateId.trim().toUpperCase();
    _validateUserId(delegateId);

    await _firestore.runTransaction((transaction) async {
      final delegateRef = _ref.doc(delegateId);
      final teamMemberRef = _firestore
          .collection(_teamMembersCollection)
          .doc(delegateId);

      final existingDelegate = await transaction.get(delegateRef);
      if (existingDelegate.exists) {
        throw StateError('Delegate ID $delegateId is already in use.');
      }

      final existingTeamMember = await transaction.get(teamMemberRef);
      if (existingTeamMember.exists) {
        throw StateError('ID $delegateId is already used by a team member.');
      }

      transaction.set(
        delegateRef,
        delegate.copyWith(delegateId: delegateId).toMap(),
      );
    });
  }

  Future<List<DelegateModel>> getDelegates() async {
    final snapshot = await _firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => DelegateModel.fromMap(doc.data())).toList();
  }

  Stream<List<DelegateModel>> streamDelegates() {
    return _ref.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => DelegateModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<DelegateModel?> getDelegateById(String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();

    if (!doc.exists) return null;

    return DelegateModel.fromMap(
      doc.data()!,
    );
  }

  Future<void> updateDelegate(DelegateModel delegate) async {
    await _firestore
        .collection(collection)
        .doc(delegate.delegateId)
        .update(delegate.toMap());
  }

  Future<void> deleteDelegate(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  Future<List<DelegateModel>> searchDelegates(String keyword) async {
    final query = keyword.trim().toLowerCase();
    if (query.isEmpty) return getDelegates();
    final delegates = await getDelegates();
    return delegates.where((delegate) {
      return delegate.name.toLowerCase().contains(query) ||
          delegate.cnic.toLowerCase().contains(query) ||
          delegate.delegateId.toLowerCase().contains(query);
    }).toList();
  }

  Future<List<DelegateModel>> searchByName(String name) {
    return searchDelegates(name);
  }

  void _validateUserId(String id) {
    if (!RegExp(r'^[A-Z][0-9]{2}$').hasMatch(id)) {
      throw ArgumentError('Delegate ID must use format A01.');
    }
  }
}
