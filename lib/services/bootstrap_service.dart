import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:projectquiche/services/error_reporting_service.dart';
import 'package:projectquiche/services/identity_service.dart';
import 'package:projectquiche/utils/safe_print.dart';

/// Initialize the (fire)base first and then other services
class BootstrapService {
  final ErrorReportingService _errorReportingService;
  final IdentityService _identityService;

  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  FirebaseDynamicLinks get _dynamicLinks => FirebaseDynamicLinks.instance;

  Uri? get initialDeepLink => _initialDeepLink;
  Uri? _initialDeepLink;

  BootstrapService(this._errorReportingService, this._identityService);

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

    _identityService.init();
    _errorReportingService.init();
  }

  /// Use this to test loading states. Uncomment prior to release.
  _maybeFakeWait() async {
    // await Future.delayed(Duration(seconds: 2));
  }

  // ---------------
  // Cloud Functions TODO extract out
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
    FirebaseFunctions.instance.useFunctionsEmulator(serverIp, 5001);
  }
}
