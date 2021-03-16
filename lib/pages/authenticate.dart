import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    return Scaffold(
        appBar: AppBar(title: Text('Project Quiche')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome!'),
              Padding(
                child: ElevatedButton(
                  child: Text('Sign in with Google'),
                  onPressed: _signInWithGoogle,
                ),
                padding: EdgeInsets.all(16),
              ),
            ],
          ),
        ));
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
}
