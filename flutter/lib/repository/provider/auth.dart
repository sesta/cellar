import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<String> getSignInUserId() async {
  return null;
  GoogleSignInAccount googleCurrentUser = _googleSignIn.currentUser;

  try {
    if (googleCurrentUser == null) {
      googleCurrentUser = await _googleSignIn.signInSilently();
    }
    if (googleCurrentUser == null) {
      return null;
    }

    final firebaseUser = await getFirebaseUser(googleCurrentUser);
    return firebaseUser.uid;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<FirebaseUser> signIn() async {
  final result = await AppleSignIn.performRequests([
    AppleIdRequest(
      requestedScopes: [Scope.fullName],
      requestedOperation: OpenIdOperation.operationLogin,
    )
  ]);

  if (result.status != AuthorizationStatus.authorized) {
    return null;
  }

  const oAuthProvider = OAuthProvider(providerId: 'apple.com');
  final credential = oAuthProvider.getCredential(
    idToken: String.fromCharCodes(result.credential.identityToken),
    accessToken: String.fromCharCodes(result.credential.authorizationCode),
  );

  return (await _auth.signInWithCredential(credential)).user;

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
