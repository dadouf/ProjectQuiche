import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Log errors and warnings to the backend
class ErrorReportingService {
  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  void init() {
    if (!kIsWeb) {
      // Pass Flutter errors to Crashlytics. This still prints to the console too.
      FlutterError.onError = _crashlytics.recordFlutterError;
    }
  }

  void recordError(dynamic exception, StackTrace? stack) {
    if (!kIsWeb) {
      _crashlytics.recordError(exception, stack);
    }
  }

  /// Note: this is not terribly useful since the logs are only "included in the
  /// next fatal or non-fatal report", but better than nothing.
  void log(String message) {
    if (!kIsWeb) {
      _crashlytics.log(message);
    }
  }

  void setUserIdentifier(String? uid) {
    if (!kIsWeb) {
      _crashlytics.setUserIdentifier(uid ?? "");
    }
  }
}
