import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:projectquiche/pages/explore_recipes.dart';
import 'package:projectquiche/pages/my_recipes.dart';
import 'package:projectquiche/pages/recipe_input.dart';

class MainAppScaffold extends StatefulWidget {
  @override
  _MainAppScaffoldState createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  Widget _currentPage = MyRecipesPage();

  // TODO could (should) that be a field of _currentPage??
  String _currentPageTitle = "My Recipes";

  @override
  Widget build(BuildContext context) {
    const paddingValue = 16.0;
    const padding = const EdgeInsets.all(paddingValue);
    return Scaffold(
        appBar: AppBar(
          title: Text(_currentPageTitle),
        ),
        drawer: Container(
          margin: EdgeInsets.only(right: 72),
          child: Material(
              color: Color(0xFF404040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: padding,
                                child: Text(
                                    "Connected as\n${FirebaseAuth.instance.currentUser?.email}"),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.logout),
                              onPressed: _logout,
                            ),
                          ],
                        ),
                        Divider(),
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
                      ],
                    ),
                  ),
                  Divider(),
                  FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        String? packageName = snapshot.data?.packageName;
                        String? version = snapshot.data?.version;
                        String? buildNumber = snapshot.data?.buildNumber;

                        const fadedColor = const Color(0x50FFFFFF);
                        return Padding(
                          padding: padding,
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: paddingValue),
                                child: Icon(
                                  Icons.info_outline,
                                  color: fadedColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "$packageName\nVersion $version+$buildNumber",
                                  style: TextStyle(color: fadedColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                ],
              )),
        ),
        body: _currentPage,
        // TODO show only in My Recipes
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
    final Function errorHandler = (error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to sign out: $error"),
      ));
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    };

    FirebaseAuth.instance
        .signOut() // this is enough to go back to Login screen
        .catchError(errorHandler);

    GoogleSignIn()
        .signOut() // this is needed in order to PROMPT user again
        .catchError(errorHandler);

    // ... causes callback in main.app
  }
}
