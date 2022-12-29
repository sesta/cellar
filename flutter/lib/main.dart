import 'dart:io';
import 'app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:cellar/firebase_options.dart';
import 'package:cellar/repository/alert_repository.dart';

main() async {
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    FirebaseCrashlytics.instance.recordFlutterError(details);

    AlertRepository().send(
      'アプリがクラッシュしました',
      details.toString(),
    );

    if (kReleaseMode) {
      exit(1);
    }
  };

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Cellar());
}

