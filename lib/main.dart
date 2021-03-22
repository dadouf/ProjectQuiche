import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/pages/authenticate.dart';
import 'package:projectquiche/pages/main_app_scaffold.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Pass Flutter errors to Crashlytics. This still prints to the console too.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(QuicheApp());
}

class QuicheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData.dark().copyWith(accentColor: Color(0xFFDC5445)),
      home: getLandingPage(),
      // initialRoute: '/',
      // routes: <String, WidgetBuilder>{
      //   '/': (BuildContext context) => AuthenticatePage(),
      // },
    );
  }

  Widget getLandingPage() {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        log("Logged in user ID: ${snapshot.data?.uid}, email: ${snapshot.data?.email}");

        if (snapshot.hasData && snapshot.data?.isAnonymous != true) {
          FirebaseCrashlytics.instance
              .setUserIdentifier(snapshot.data?.uid ?? "");
          return MainAppScaffold();
        }

        return AuthenticatePage();
      },
    );
  }
}
