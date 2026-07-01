import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
}
