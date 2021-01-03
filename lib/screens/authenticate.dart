import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticatePage extends StatefulWidget {
  @override
  _AuthenticatePageState createState() {
    return _AuthenticatePageState();
  }
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  String _displayName = '???';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Project Quiche')),
        body: Column(children: [
          Text('Bonjour'),
          Text('Authenticated: ' + _displayName),
          RaisedButton(
            child: Text('Authenticate with Google'),
            onPressed: _signInWithGoogle,
          )
        ]));
  }

  Future<UserCredential> _signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    setState(() {
      _displayName = userCredential.user.displayName;
    });

    return userCredential;
  }
}
