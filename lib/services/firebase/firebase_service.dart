import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:projectquiche/models/app_user.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:projectquiche/utils/safe_print.dart';

class FirebaseService extends ChangeNotifier {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  FirebaseAnalytics? _analyticsInstance;

  FirebaseAnalytics get _analytics {
    if (_analyticsInstance == null) {
      _analyticsInstance = FirebaseAnalytics();
    }
    return _analyticsInstance!;
  }

  /// false == Firebase hasn't init yet
  /// true == Firebase has init at least the first user (may be null or not)
  bool get hasBootstrapped => _hasBootstrapped;
  bool _hasBootstrapped = false;

  User? get firebaseUser => _firebaseUser;
  User? _firebaseUser;

  AppUser? get appUser => _appUser;
  AppUser? _appUser;

  Future<void> init() async {
    // Must initializeApp before ANY other Firebase calls
    await Firebase.initializeApp().catchError((Object e) {
      safePrint("FirebaseService: failed to init Firebase: $e");
    }).then((value) {
      safePrint("FirebaseService: init complete");
    });

    _auth.userChanges().listen((User? firebaseUser) async {
      safePrint("FirebaseService: user changed $firebaseUser");

      if (!kIsWeb) {
        _crashlytics.setUserIdentifier(firebaseUser?.uid ?? "");
      }
      _analytics.setUserId(firebaseUser?.uid);

      _firebaseUser = firebaseUser;

      if (firebaseUser == null) {
        _hasBootstrapped = true;
      } else {
        try {
          final userDoc = await MyFirestore.users().doc(firebaseUser.uid).get();
          if (userDoc.exists) {
            _appUser = AppUser.fromDocument(userDoc);
          }
        } on Exception catch (e, s) {
          _crashlytics.recordError(e, s);
        } finally {
          _hasBootstrapped = true;
        }
      }
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

  Future<void> signIn({required OAuthCredential credential, required String method}) async {
    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.additionalUserInfo?.isNewUser == true) {
      _analytics.logSignUp(signUpMethod: method);
    } else {
      _analytics.logLogin(loginMethod: method);
    }
  }

  Future<void> signOut() async {
    _appUser = null;
    await _auth.signOut();

    _analytics.logEvent(name: "logout");
  }

  Future<void> completeProfile(
      String username, AvatarType selectedAvatar) async {
    try {
      await MyFirestore.users().doc(_firebaseUser!.uid).set({
        MyFirestore.fieldUsername: username,
        MyFirestore.fieldAvatarUrl: selectedAvatar == AvatarType.social
            ? _firebaseUser?.photoURL
            : null,
        MyFirestore.fieldAvatarSymbol: selectedAvatar.code,
      });
      _appUser = AppUser(uid: _firebaseUser!.uid, username: username);
      notifyListeners();
    } on Exception catch (e, stack) {
      // TODO
    }
  }

  // -----------
  // Crashlytics
  // -----------

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

  // ---------
  // Analytics
  // ---------

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
