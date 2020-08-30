import 'package:flutter/material.dart';
import 'package:projectquiche/screens/authenticate.dart';
import 'package:projectquiche/screens/recipe_list.dart';

void main() => runApp(QuicheApp());

class QuicheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => AuthenticatePage(),
      },
    );
  }
}
