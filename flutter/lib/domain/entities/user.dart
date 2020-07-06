import 'dart:async';

import 'package:cellar/repository/provider/firestore.dart';

class User {
  String id;
  String name;

  User(
      this.id,
      this.name,
  );

  Future<void> addStore() async {
    addData('users', {
      'name': name,
    }, id);
  }

  @override
  String toString() {
    return 'id: ${this.id}, name: ${this.name}';
  }
}
