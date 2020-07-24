import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

enum EventType {
  PostDrink,
  EditDrink,
  DeleteDrink,
  ChangeTimelineType,
  ChangeDrinkType,
  ChangeOrderType,
  ReloadTimeline,
  EditUserName,
}

class AnalyticsRepository {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics();
  static final FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(
    analytics: _analytics,
  );

  Future<void> setUser(String userId) async {
    await _analytics.setUserId(userId);
  }

  Future<void> sendEvent(
    EventType eventType,
    Map<String, String> parameters,
  ) async{
    await _analytics.logEvent(
      name: eventType.toString(),
      parameters: parameters,
    );
  }

  FirebaseAnalyticsObserver get observer => _observer;
}
