import 'package:cloud_firestore/cloud_firestore.dart';

class DB {
  static Firestore _db = Firestore.instance;

  Firestore get db => _db;
}
