import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Methods to get auth tokens from allowed providers,
/// and pass them to [FirebaseService] for authentication.
class AuthService {
  final FirebaseService firebaseService;

  AuthService(this.firebaseService);

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

      await firebaseService.signIn(credential: credential, method: "Google");
    } catch (e, trace) {
      firebaseService.recordError(e, trace);
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

      await firebaseService.signIn(credential: credential, method: "Apple");
    } catch (e, trace) {
      firebaseService.recordError(e, trace);
      rethrow;
    }
  }
}
