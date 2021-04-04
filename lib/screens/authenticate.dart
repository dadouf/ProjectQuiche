import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthenticateScreen extends StatefulWidget {
  @override
  _AuthenticateScreenState createState() {
    return _AuthenticateScreenState();
  }
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  @override
  Widget build(BuildContext context) {
    const edgeInsets = EdgeInsets.all(16);

    final originalScheme = Theme.of(context).colorScheme;
    final boldColorScheme = originalScheme.copyWith(
      background: originalScheme.primary,
      onBackground: originalScheme.onPrimary,
      primary: originalScheme.background,
      onPrimary: originalScheme.onBackground,
    );

    return Theme(
      data: boldColorScheme.toTheme(),
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Padding(
              padding: edgeInsets,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 92,
                    color: Colors.white,
                  ),
                  Container(
                    child: Text(
                      "Project Quiche",
                      style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 64),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ElevatedButton(
                      child: Container(
                        alignment: Alignment.center,
                        height: 44, // to match Apple
                        child: Text(
                          AppLocalizations.of(context)!.signInWithGoogle,
                          style:
                              TextStyle(fontSize: 44 * 0.43), // to match Apple
                        ),
                      ),
                      onPressed: _signInWithGoogle,
                    ),
                  ),
                  if (!kIsWeb && Platform.isIOS)
                    SignInWithAppleButton(
                      onPressed: _signInWithApple,
                      text: AppLocalizations.of(context)!.signInWithApple,
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _signIn(credential: credential, method: "Google");
    } on Exception catch (e, stackTrace) {
      _handleError(e, stackTrace);
    }
  }

  Future<void> _signInWithApple() async {
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
    } on Exception catch (e, stackTrace) {
      _handleError(e, stackTrace);
    }
  }

  Future<void> _signIn({
    required OAuthCredential credential,
    required String method,
  }) async {
    await context
        .read<FirebaseService>()
        .signIn(credential: credential, method: method);
  }

  void _handleError(exception, trace) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Failed to sign in: $exception"),
    ));
    context.read<FirebaseService>().recordError(exception, trace);
  }
}
