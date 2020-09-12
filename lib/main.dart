import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/screens/authenticate.dart';
import 'package:projectquiche/screens/recipe_list.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(new MaterialApp(
    theme: ThemeData.dark(),
    home: await getLandingPage(),
    // initialRoute: '/',
    // routes: <String, WidgetBuilder>{
    //   '/': (BuildContext context) => AuthenticatePage(),
    // },
  ));
}

Future<Widget> getLandingPage() async {
  return StreamBuilder<User>(
    stream: _auth.authStateChanges(),
    builder: (BuildContext context, snapshot) {
      if (snapshot.hasData && (!snapshot.data.isAnonymous)) {
        return RecipeListPage();
      }

      return AuthenticatePage();
    },
  );
}
