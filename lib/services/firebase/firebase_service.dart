import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:projectquiche/utils/safe_print.dart';

class FirebaseService extends ChangeNotifier {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  FirebaseAnalytics? _analyticsInstance;

  FirebaseAnalytics get _analytics {
    if (_analyticsInstance == null) {
      _analyticsInstance = FirebaseAnalytics();
    }
    return _analyticsInstance!;
  }

  bool get isSignedIn => _isSignedIn;
  bool _isSignedIn = false;

  Future<void> init() async {
    // Must initializeApp before ANY other Firebase calls
    await Firebase.initializeApp().catchError((Object e) {
      safePrint("FirebaseService: failed to init Firebase: $e");
    }).then((value) {
      safePrint("FirebaseService: init complete");
    });

    FirebaseAuth.instance.userChanges().listen((User? user) {
      safePrint("FirebaseService: user changed $user");

      if (!kIsWeb) {
        _crashlytics.setUserIdentifier(user?.uid ?? "");
        // TODO keep User in the model so that we can refer to it
      }
      _analytics.setUserId(user?.uid);

      _isSignedIn = user != null;
      notifyListeners();
    });

    if (!kIsWeb) {
      // Pass Flutter errors to Crashlytics. This still prints to the console too.
      FlutterError.onError = _crashlytics.recordFlutterError;
    }
  }

  // ----
  // Auth
  // ----

  Future<void> signIn(
      {required OAuthCredential credential, required String method}) async {
    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.additionalUserInfo?.isNewUser == true) {
      _analytics.logSignUp(signUpMethod: method);
    } else {
      _analytics.logLogin(loginMethod: method);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();

    _analytics.logEvent(name: "logout");
  }

  // -----------
  // Crashlytics
  // -----------

  void recordError(dynamic exception, StackTrace? stack) {
    if (!kIsWeb) {
      _crashlytics.recordError(exception, stack);
    }
  }

  // ---------
  // Analytics
  // ---------

  void logSave() {
    _analytics.logEvent(name: "save_recipe");
  }

  void logMoveToBin() {
    _analytics.logEvent(name: "move_to_bin");
  }
}
