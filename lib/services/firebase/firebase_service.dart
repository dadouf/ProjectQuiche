import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projectquiche/data/app_user.dart';
import 'package:projectquiche/services/error_reporting_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:projectquiche/utils/safe_print.dart';

/// TODO break into multiple services, each one dedicated to one thing:
/// 1. BootstrapService (init Firebase, check deeplink)
/// 2. ErrorReportingService
/// 3. AnalyticsService
/// 4. IdentityService (check Firebase user and AppUser)
class FirebaseService extends ChangeNotifier {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  final ErrorReportingService _errorReportingService;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  FirebaseAnalytics? _analyticsInstance;

  FirebaseAnalytics get _analytics {
    if (_analyticsInstance == null) {
      _analyticsInstance = FirebaseAnalytics();
    }
    return _analyticsInstance!;
  }

  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  FirebaseDynamicLinks get _dynamicLinks => FirebaseDynamicLinks.instance;

  /// false == Firebase hasn't init yet
  /// true == Firebase has init at least the first user (may be null or not)
  bool get hasBootstrapped => _hasBootstrapped;
  bool _hasBootstrapped = false;

  Uri? get initialDeepLink => _initialDeepLink;
  Uri? _initialDeepLink;

  User? get firebaseUser => _firebaseUser;
  User? _firebaseUser;

  // TODO this ideally shouldn't be held here, but in AppModel
  AppUser? get appUser => _appUser;
  AppUser? _appUser;

  FirebaseService(this._errorReportingService);

  Future<void> init() async {
    // Must initializeApp before ANY other Firebase calls
    try {
      await _maybeFakeWait();

      await Firebase.initializeApp();

      // _useFirebaseEmulator();

      safePrint("FirebaseService: init complete");
    } catch (e, trace) {
      safePrint("FirebaseService: failed to init Firebase: $e, $trace");
    }

    _initialDeepLink = (await _dynamicLinks.getInitialLink())?.link;
    safePrint("INITIAL DEEPLINK: ${_initialDeepLink?.toString()}");

    _dynamicLinks.onLink(
      onSuccess: (PendingDynamicLinkData? dynamicLink) async {
        final Uri? deepLink = dynamicLink?.link;
        safePrint("ON DEEPLINK: ${deepLink?.toString()}");
      },
      onError: (OnLinkErrorException e) async {
        _errorReportingService.recordError(e, null);
      },
    );

    // TODO: update the App Model when receiving a deep link

    _auth.userChanges().listen((User? firebaseUser) async {
      safePrint("FirebaseService: user changed $firebaseUser");

      _errorReportingService.setUserIdentifier(firebaseUser?.uid);
      _analytics.setUserId(firebaseUser?.uid);

      _firebaseUser = firebaseUser;

      if (firebaseUser == null) {
        _hasBootstrapped = true;
      } else {
        try {
          await _maybeFakeWait();

          final userDoc = await MyFirestore.users().doc(firebaseUser.uid).get();
          if (userDoc.exists) {
            _appUser = AppUser.fromDocument(userDoc);
          }
        } catch (e, trace) {
          _errorReportingService.recordError(e, trace);
        } finally {
          _hasBootstrapped = true;
        }
      }
      notifyListeners();
    });

    _errorReportingService.init();
  }

  /// Use this to test loading states. Uncomment prior to release.
  _maybeFakeWait() async {
    // await Future.delayed(Duration(seconds: 2));
  }

  // ----
  // Auth
  // ----

  Future<void> signIn({
    required OAuthCredential credential,
    required String method,
  }) async {
    try {
      await _maybeFakeWait();

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        _analytics.logSignUp(signUpMethod: method);
      } else {
        _analytics.logLogin(loginMethod: method);
      }
    } catch (e, trace) {
      _errorReportingService.recordError(e, trace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    _analytics.logEvent(name: "logout");

    _appUser = null;

    try {
      await _maybeFakeWait();
      // TODO stop listening to firebase before, otherwise a permission-denied error is thrown

      // This is enough to go back to Login screen
      await _auth.signOut();

      // This is needed in order to PROMPT user again
      await GoogleSignIn().signOut();

      // ... will cause AppModel update because FirebaseService.isSignedIn will change
    } catch (e, trace) {
      _errorReportingService.recordError(e, trace);
      rethrow;
    }
  }

  Future<void> createProfile(
    String username,
    AvatarType selectedAvatar,
  ) async {
    try {
      await _maybeFakeWait();

      final avatarUrl =
          selectedAvatar == AvatarType.custom ? _firebaseUser?.photoURL : null;

      await MyFirestore.users().doc(_firebaseUser!.uid).set({
        MyFirestore.fieldUsername: username,
        MyFirestore.fieldAvatarUrl: avatarUrl,
        MyFirestore.fieldAvatarSymbol: selectedAvatar.code,
      });

      _appUser = AppUser(
        userId: _firebaseUser!.uid,
        username: username,
        avatarType: AvatarType.from(selectedAvatar.code),
        avatarUrl: avatarUrl,
      );

      notifyListeners();
    } catch (e, trace) {
      _errorReportingService.recordError(e, trace);
      rethrow;
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

  // ---------------
  // Cloud Functions
  // ---------------

  Future<String> generateUsername() async {
    try {
      await _maybeFakeWait();

      HttpsCallable callable = _functions.httpsCallable("generateUsername");
      final results = await callable();

      return results.data["username"];
    } catch (e, trace) {
      _errorReportingService.recordError(e, trace);
      rethrow;
    }
  }

  void _useFirebaseEmulator() {
    if (kReleaseMode) return;

    final serverIp = "192.168.86.184"; // change to local computer

    FirebaseFirestore.instance.settings =
        Settings(host: "$serverIp:8080", sslEnabled: false);
    FirebaseFunctions.instance
        .useFunctionsEmulator(origin: "http://$serverIp:5001");
  }
}
