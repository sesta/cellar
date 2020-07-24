import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsRepository {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics();
  static final FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(
    analytics: _analytics,
  );

  FirebaseAnalyticsObserver get observer => _observer;
}
