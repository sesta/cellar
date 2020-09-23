import 'package:cloud_firestore/cloud_firestore.dart';

class DB {
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get db => _db;
}
