import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthenticatePage extends StatefulWidget {
  @override
  _AuthenticatePageState createState() {
    return _AuthenticatePageState();
  }
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  @override
  Widget build(BuildContext context) {
    // TODO loading state
    const edgeInsets = EdgeInsets.all(16);
    return Scaffold(
        appBar: AppBar(title: Text('Project Quiche')),
        body: Center(
            child: Padding(
          padding: edgeInsets,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                child: Text(
                  'Welcome!',
                  style: TextStyle(fontSize: 18),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.all(32),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  child: Container(
                    alignment: Alignment.center,
                    height: 44, // to match Apple
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(fontSize: 44 * 0.43), // to match Apple
                    ),
                  ),
                  onPressed: _signInWithGoogle,
                ),
              ),
              if (Platform.isIOS)
                SignInWithAppleButton(
                  onPressed: _signInWithApple,
                )
            ],
          ),
        )));
  }

  Future<UserCredential?> _signInWithGoogle() async {
    final Function errorHandler = (error, stackTrace) {
      final reason = "Failed to sign in";
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(reason)));
      FirebaseCrashlytics.instance
          .recordError(error, stackTrace, reason: reason);
    };

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn().catchError(errorHandler);

    if (googleUser == null) {
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential)
        .catchError(errorHandler);

    return userCredential;
  }

  void _signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final AuthCredential oauthCredential =
        OAuthProvider('apple.com').credential(
      accessToken: appleCredential.authorizationCode,
      idToken: appleCredential.identityToken,
    );

    // Once signed in, return the UserCredential
    final userCredential = await FirebaseAuth.instance
        .signInWithCredential(oauthCredential)
        .catchError((error) {
      print("Apple error: $error");
    });

    print("Apple success");
    // print(credential);

    // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
    // after they have been validated with Apple (see `Integration` section for more information on how to do this)
  }
}
