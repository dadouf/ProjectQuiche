import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/model/recipe.dart';
import 'package:projectquiche/pages/recipe.dart';

class MyRecipesPage extends StatefulWidget {
  @override
  _MyRecipesPageState createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage>
    with StreamSubscriberMixin {
  final _recipesDbRef =
      FirebaseDatabase.instance.reference().child("v1/recipes");
  final _recipesDbConverter = RecipesConverter();

  List<Recipe> _recipes = [];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _recipes.length,
        itemBuilder: (context, position) {
          var _recipe = _recipes[position];
          return ListTile(
            title: Text(_recipe.name),
            onTap: () => _openRecipe(context, _recipe),
          );
        });
  }

  @override
  void initState() {
    super.initState();

    // TODO move one layer down
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
}
