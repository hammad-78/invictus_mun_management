import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  Future<void> setDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return collection(collectionPath).doc(documentId).set(data);
  }

  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return collection(collectionPath).doc(documentId).update(data);
  }

  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) {
    return collection(collectionPath).doc(documentId).delete();
  }
}
