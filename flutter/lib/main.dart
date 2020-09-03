import 'dart:io';
import 'app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:cellar/repository/alert_repository.dart';

main() {
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    Crashlytics.instance.recordFlutterError(details);

    AlertRepository().send(
      'アプリがクラッシュしました',
      details.toString(),
    );

    if (kReleaseMode) {
      exit(1);
    }
  };

  runApp(Cellar());
}

