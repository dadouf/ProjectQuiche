import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/model/recipe.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Project Quiche')),
        body: ListView.builder(
            itemCount: _recipes.length,
            itemBuilder: (context, position) {
              var _recipe = _recipes[position];
              return ListTile(
                title: Text(_recipe.name),
                onTap: () => _openRecipe(context, _recipe),
              );
            }));
  }

  @override
  void initState() {
    super.initState();

    listen(
        _recipesDbRef.onValue,
        (event) => setState(() {
              _recipes = _recipesDbConverter.convert(event.snapshot.value);
            }));
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
