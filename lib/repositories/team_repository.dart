import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/team_member_model.dart';

class TeamRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = "team_members";
  final String _delegatesCollection = "delegates";

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(collection);

  Future<void> addMember(TeamMemberModel member) async {
    final memberId = member.memberId.trim().toUpperCase();
    _validateUserId(memberId);

    await _firestore.runTransaction((transaction) async {
      final memberRef = _ref.doc(memberId);
      final delegateRef = _firestore
          .collection(_delegatesCollection)
          .doc(memberId);

      final existingMember = await transaction.get(memberRef);
      if (existingMember.exists) {
        throw StateError('Member ID $memberId is already in use.');
      }

      final existingDelegate = await transaction.get(delegateRef);
      if (existingDelegate.exists) {
        throw StateError('ID $memberId is already used by a delegate.');
      }

      transaction.set(
        memberRef,
        member.copyWith(memberId: memberId).toMap(),
      );
    });
  }

  Future<List<TeamMemberModel>> getMembers() async {
    final snapshot = await _firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TeamMemberModel.fromMap(doc.data()))
        .toList();
  }

  Stream<List<TeamMemberModel>> streamMembers() {
    return _ref.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => TeamMemberModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<TeamMemberModel?> getMemberById(String memberId) async {
    final doc = await _ref.doc(memberId).get();
    if (!doc.exists || doc.data() == null) return null;
    return TeamMemberModel.fromMap(doc.data()!);
  }

  Future<void> updateMember(TeamMemberModel member) async {
    await _firestore
        .collection(collection)
        .doc(member.memberId)
        .update(member.toMap());
  }

  Future<void> deleteMember(String memberId) async {
    await _firestore
        .collection(collection)
        .doc(memberId)
        .delete();
  }

  Future<List<TeamMemberModel>> searchMember(String keyword) async {
    final query = keyword.trim().toLowerCase();
    if (query.isEmpty) return getMembers();
    final members = await getMembers();
    return members.where((member) {
      return member.name.toLowerCase().contains(query) ||
          member.memberId.toLowerCase().contains(query);
    }).toList();
  }

  void _validateUserId(String id) {
    if (!RegExp(r'^[A-Z][0-9]{2}$').hasMatch(id)) {
      throw ArgumentError('Member ID must use format A01.');
    }
  }
}
