import 'package:firebase_analytics/firebase_analytics.dart';

/// Log events to the backend
class AnalyticsService {
  FirebaseAnalytics? _analyticsInstance;

  FirebaseAnalytics get _analytics {
    final instance = _analyticsInstance;
    if (instance != null) {
      return instance;
    } else {
      final newInstance = FirebaseAnalytics();
      _analyticsInstance = newInstance;
      return newInstance;
    }
  }

  void setUserId(String? uid) {
    _analytics.setUserId(uid);
  }

  void logSignUp({required String signUpMethod}) {
    _analytics.logSignUp(signUpMethod: signUpMethod);
  }

  void logLogin({required String loginMethod}) {
    _analytics.logLogin(loginMethod: loginMethod);
  }

  void logLogout() {
    _analytics.logEvent(name: "logout");
  }

  void logSave() {
    _analytics.logEvent(name: "save_recipe");
  }

  void logMoveToBin() {
    _analytics.logEvent(name: "move_to_bin");
  }

  void logLoadMore(int length, bool autoTriggered) {
    _analytics.logEvent(name: "load_more_recipes", parameters: {
      "loaded_count": length,
      "auto_triggered": autoTriggered,
    });
  }
}
