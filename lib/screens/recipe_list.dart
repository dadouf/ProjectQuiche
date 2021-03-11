import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projectquiche/model/recipe.dart';
import 'package:projectquiche/screens/new_recipe.dart';
import 'package:projectquiche/screens/recipe.dart';

class RecipeListPage extends StatefulWidget {
  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage>
    with StreamSubscriberMixin {
  final _recipesDbRef =
      FirebaseDatabase.instance.reference().child("v1/recipes");
  final _recipesDbConverter = RecipesConverter();

  List<Recipe> _recipes = [];

  String _currentPageTitle = "All Recipes";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_currentPageTitle),
        ),
        drawer: Container(
            color: Color(0xFF404040),
            margin: EdgeInsets.only(right: 72),
            // width: 250,
            child: ListView(
              children: [
                ListTile(
                  title: Text("All Recipes"),
                  onTap: () {
                    setState(() {
                      _currentPageTitle = "All Recipes";
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text("My Recipes"),
                  onTap: () {
                    setState(() {
                      _currentPageTitle = "My Recipes";
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Row(
                    children: [Icon(Icons.logout), Text("Log out")],
                  ),
                  onTap: _logout,
                )
              ],
            )),
        body: ListView.builder(
            itemCount: _recipes.length,
            itemBuilder: (context, position) {
              var _recipe = _recipes[position];
              return ListTile(
                title: Text(_recipe.name),
                onTap: () => _openRecipe(context, _recipe),
              );
            }),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.plus_one),
          onPressed: () => _addStuff(),
        ));
  }

  @override
  void initState() {
    super.initState();

    listen(
        _recipesDbRef.onValue,
        (event) => setState(() {
              _recipes = _recipesDbConverter.convert(event.snapshot.value);
            }), onError: (error) {
      log("Error while listening to recipe list", error: error);
    });
  }

  @override
  void dispose() {
    cancelSubscriptions();

    super.dispose();
  }

  void _openRecipe(BuildContext context, Recipe recipe) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RecipePage(recipe)));
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
