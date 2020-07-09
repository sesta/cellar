import 'dart:async';

import 'package:cellar/repository/provider/firestore.dart';

class User {
  String id;
  String userName;

  User(
      this.id,
      this.userName,
  );

  Future<void> addStore() async {
    addData('users', {
      'userName': userName,
    }, id);
  }

  @override
  String toString() {
    return 'id: ${this.id}, userName: ${this.userName}';
  }
}
