import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:projectquiche/utils/safe_print.dart';

class FirebaseService extends ChangeNotifier {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

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

      _isSignedIn = user != null;
      notifyListeners();
    });

    if (!kIsWeb) {
      // Pass Flutter errors to Crashlytics. This still prints to the console too.
      FlutterError.onError = _crashlytics.recordFlutterError;
    }
  }

  Future<void> signIn(OAuthCredential credential) async {
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void recordError(dynamic exception, StackTrace? stack) {
    if (!kIsWeb) {
      _crashlytics.recordError(exception, stack);
    }
  }
}
