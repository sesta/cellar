import 'dart:async';

import 'package:bacchus/domain/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<User> signIn() async {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignInAccount googleCurrentUser = _googleSignIn.currentUser;

  try {
    if (googleCurrentUser == null) googleCurrentUser = await _googleSignIn.signInSilently();
    if (googleCurrentUser == null) googleCurrentUser = await _googleSignIn.signIn();
    if (googleCurrentUser == null) return null;

    GoogleSignInAuthentication googleAuth = await googleCurrentUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    return User(user.uid, user.displayName);
  } catch (e) {
    print(e);
    return null;
  }
}
