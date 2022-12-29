import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:cellar/domain/entity/entities.dart';

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

extension EventTypeExtension on EventType {
  // Firebase Analyticsのイベントはアルファベット + '_' しか許してくれないので整形
  // https://firebase.google.com/docs/reference/cpp/group/event-names
  String get name {
    switch(this) {
      case EventType.PostDrink: return 'post_drink';
      case EventType.EditDrink: return 'edit_drink';
      case EventType.DeleteDrink: return 'delete_drink';
      case EventType.ChangeTimelineType: return 'change_timeline_type';
      case EventType.ChangeDrinkType: return 'change_drink_type';
      case EventType.ChangeOrderType: return 'change_order_type';
      case EventType.ReloadTimeline: return 'reload_timeline';
      case EventType.EditUserName: return 'edit_user_name';
    }

    throw '存在しないtypeです。 $this';
  }
}

class AnalyticsRepository {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(
    analytics: _analytics,
  );

  Future<void> setUser(User user) async {
    await _analytics.setUserId(id: user.userId);
    await _analytics.setUserProperty(name: 'user_id', value: user.userId);
    await _analytics.setUserProperty(name: 'is_developer', value: user.isDeveloper.toString());
  }

  Future<void> sendEvent(
    EventType eventType,
    Map<String, String> parameters,
  ) async{
    await _analytics.logEvent(
      name: eventType.name,
      parameters: parameters,
    );
  }

  FirebaseAnalyticsObserver get observer => _observer;
}
