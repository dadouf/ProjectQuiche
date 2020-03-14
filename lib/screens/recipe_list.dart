import 'package:flutter/material.dart';
import 'package:projectquiche/model/local_database.dart';
import 'package:projectquiche/model/models.dart';
import 'package:projectquiche/screens/recipe.dart';

class RecipeListPage extends StatelessWidget {
  final _recipes = <Recipe>[cremeVichyssoise];

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

  void _openRecipe(BuildContext context, Recipe recipe) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return RecipePage(recipe);
    }));
  }
}
