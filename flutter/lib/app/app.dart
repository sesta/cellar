import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:bacchus/app/pages/home.dart';

class Bacchus extends StatefulWidget {
  Bacchus({Key key}) : super(key: key);

  @override
  _BacchusState createState() => _BacchusState();
}

class _BacchusState extends State<Bacchus> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String userId = null;

  Future<String> _signIn() async {
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
      print(user.displayName);
      print(user.uid);
      print(user.email);

      return user.uid;
    } catch (e) {
      print(e);
      return null;
    }
  }


  @override
  void initState() {
    super.initState();

    _signIn().then((userId) {
      setState(() {
        userId = userId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bacchus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Home'),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}

