import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/screens/authenticate.dart';
import 'package:projectquiche/screens/cloud_recipe_list.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(QuicheApp());
}

class QuicheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData.dark(),
      home: getLandingPage(),
      // initialRoute: '/',
      // routes: <String, WidgetBuilder>{
      //   '/': (BuildContext context) => AuthenticatePage(),
      // },
    );
  }

  Widget getLandingPage() {
    return StreamBuilder<User>(
      stream: _auth.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData && !snapshot.data.isAnonymous) {
          return CloudRecipeListPage();
          // return RecipeListPage();
        }

        return AuthenticatePage();
      },
    );
  }
}
