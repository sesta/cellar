import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:bacchus/domain/entities/user.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<User> getSignInUser() async {
  GoogleSignInAccount googleCurrentUser = _googleSignIn.currentUser;

  try {
    if (googleCurrentUser == null) {
      googleCurrentUser = await _googleSignIn.signInSilently();
    }
    if (googleCurrentUser == null) {
      return null;
    }

    final firebaseUser = await getFirebaseUser(googleCurrentUser);

    // TOOD: ユーザー情報をstoreから取得する
    return User(firebaseUser.uid, firebaseUser.displayName);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<FirebaseUser> signIn() async {
  GoogleSignInAccount googleCurrentUser = _googleSignIn.currentUser;

  try {
    if (googleCurrentUser == null) {
      googleCurrentUser = await _googleSignIn.signIn();
    }
    if (googleCurrentUser == null) {
      return null;
    }
    return await getFirebaseUser(googleCurrentUser);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<FirebaseUser> getFirebaseUser(
    GoogleSignInAccount googleCurrentUser,
) async {
  GoogleSignInAuthentication googleAuth = await googleCurrentUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  return (await _auth.signInWithCredential(credential)).user;
}
