import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in.dart';

enum AuthType {
  Google,
  Apple,
}

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signIn(AuthType authType) async {
    AuthCredential credential;
    switch (authType) {
      case AuthType.Apple:
        credential = await _getCredentialByApple();
        break;
      case AuthType.Google:
        credential = await _getCredentialByGoogle();
        break;
    }

    if (credential == null) {
      return null;
    }
    final firebaseUser = await _auth.signInWithCredential(credential);
    return firebaseUser.user.uid;
  }

  Future<AuthCredential> _getCredentialByApple() async {
    final result = await AppleSignIn.performRequests([
      AppleIdRequest(
        requestedOperation: OpenIdOperation.operationLogin,
      )
    ]);
    if (result.status != AuthorizationStatus.authorized) {
      return null;
    }

    final oAuthProvider = OAuthProvider(providerId: 'apple.com');
    return oAuthProvider.getCredential(
      idToken: String.fromCharCodes(result.credential.identityToken),
      accessToken: String.fromCharCodes(result.credential.authorizationCode),
    );
  }

  Future<AuthCredential> _getCredentialByGoogle() async {
    final googleCurrentUser = await _googleSignIn.signIn();
    if (googleCurrentUser == null) {
      return null;
    }

    GoogleSignInAuthentication googleAuth = await googleCurrentUser.authentication;
    return GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }
}