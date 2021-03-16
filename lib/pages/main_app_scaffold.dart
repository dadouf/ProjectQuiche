import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projectquiche/pages/explore_recipes.dart';
import 'package:projectquiche/pages/my_recipes.dart';
import 'package:projectquiche/pages/new_recipe.dart';

class MainAppScaffold extends StatefulWidget {
  @override
  _MainAppScaffoldState createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  Widget _currentPage = ExploreRecipesPage();

  // TODO could (should) that be a field of _currentPage??
  String _currentPageTitle = "Explore Recipes";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_currentPageTitle),
        ),
        drawer: Container(
          margin: EdgeInsets.only(right: 72),
          child: Material(
              color: Color(0xFF404040),
              child: ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                            "Connected as ${FirebaseAuth.instance.currentUser?.displayName}\n${FirebaseAuth.instance.currentUser?.email}"),
                      )),
                      IconButton(icon: Icon(Icons.logout), onPressed: _logout)
                    ],
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Explore Recipes"),
                    onTap: () {
                      setState(() {
                        _currentPage = ExploreRecipesPage();
                        _currentPageTitle = "Explore Recipes";
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text("My Recipes"),
                    onTap: () {
                      setState(() {
                        _currentPage = MyRecipesPage();
                        _currentPageTitle = "My Recipes";
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )),
        ),
        body: _currentPage,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.plus_one),
          onPressed: () => _addStuff(),
        ));
  }

  void _addStuff() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewRecipePage()));
  }

  void _logout() {
    FirebaseAuth.instance
        .signOut(); // this is enough to go back to Login screen
    GoogleSignIn().signOut(); // this is needed in order to PROMPT user again

    // ... causes callback in main.app
  }
}
