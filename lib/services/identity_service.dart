import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projectquiche/data/app_user.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/services/analytics_service.dart';
import 'package:projectquiche/services/error_reporting_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:projectquiche/utils/safe_print.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Track and change the identity of the current user, that is both
/// the Firebase [User] and the [AppUser] that is built on top.
class IdentityService {
  final ErrorReportingService _errorReportingService;
  final AnalyticsService _analyticsService;
  final AppModel _appModel;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  IdentityService(
    this._errorReportingService,
    this._analyticsService,
    this._appModel,
  );

  void init() {
    _auth.userChanges().listen((User? firebaseUser) async {
      safePrint("FirebaseService: user changed $firebaseUser");

      _errorReportingService.setUserIdentifier(firebaseUser?.uid);
      _analyticsService.setUserId(firebaseUser?.uid);

      if (firebaseUser == null) {
        _appModel.setUser(null, null);
      } else {
        try {
          final userDoc = await MyFirestore.users().doc(firebaseUser.uid).get();
          if (userDoc.exists) {
            _appModel.setUser(firebaseUser, AppUser.fromDocument(userDoc));
          }
        } catch (e, trace) {
          _errorReportingService.recordError(e, trace);
          _appModel.setUser(firebaseUser, null);
        }
      }
    });
  }

  /// Prompt the Sign in with Google flow, then return to the app.
  /// This method throws if it failed to sign in.
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _signIn(credential: credential, method: "Google");
    } catch (e, trace) {
      _errorReportingService.recordError(e, trace);
      rethrow;
    }
  }

  /// Prompt the Sign in with Apple flow, then return to the app.
  /// This methods doesn't throw: It returns false if it failed to sign in.
  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        accessToken: appleCredential.authorizationCode,
        idToken: appleCredential.identityToken,
      );

      await _signIn(credential: credential, method: "Apple");
    } catch (e, trace) {
      _errorReportingService.recordError(e, trace);
      rethrow;
    }
  }

  Future<void> _signIn({
    required OAuthCredential credential,
    required String method,
  }) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        _analyticsService.logSignUp(signUpMethod: method);
      } else {
        _analyticsService.logLogin(loginMethod: method);
      }
    } catch (e, trace) {
      _errorReportingService.recordError(e, trace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    _analyticsService.logLogout();

    _appModel.setUser(null, null); // TODO maybe we don't need this

    try {
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
    User firebaseUser,
    String username,
    AvatarType selectedAvatar,
  ) async {
    try {
      final avatarUrl =
          selectedAvatar == AvatarType.custom ? firebaseUser.photoURL : null;

      await MyFirestore.users().doc(firebaseUser.uid).set({
        MyFirestore.fieldUsername: username,
        MyFirestore.fieldAvatarUrl: avatarUrl,
        MyFirestore.fieldAvatarSymbol: selectedAvatar.code,
      });

      _appModel.setUser(
          firebaseUser,
          AppUser(
            userId: firebaseUser.uid,
            username: username,
            avatarType: AvatarType.from(selectedAvatar.code),
            avatarUrl: avatarUrl,
          ));
    } catch (e, trace) {
      _errorReportingService.recordError(e, trace);
      rethrow;
    }
  }
}
