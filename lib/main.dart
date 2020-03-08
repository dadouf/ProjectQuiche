import 'package:flutter/material.dart';
import 'package:projectquiche/local_recipes.dart';

import 'models.dart';

void main() => runApp(QuicheApp());

class QuicheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: RecipeListPage(),
    );
  }
}

class RecipeListPage extends StatelessWidget {
  final _recipes = <Recipe>[cremeVichyssoise];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project Quiche')),
      body: ListView(
        children: _recipes.map((recipe) {
          return RecipeListTile(recipe);
        }).toList(),
      ),
    );
  }
}

class RecipeListTile extends StatelessWidget {
  final Recipe recipe;

  RecipeListTile(this.recipe);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(recipe.name),
        onTap: () {
          _openRecipe(context);
        });
  }

  void _openRecipe(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(title: Text(recipe.name)),
        body: ListView(
          children: recipe.ingredients.map((ingredient) {
            return IngredientListTile(ingredient);
          }).toList(),
        ),
      );
    }));
  }
}

class IngredientListTile extends StatelessWidget {
  final Ingredient ingredient;

  IngredientListTile(this.ingredient);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(ingredient.product +
          (ingredient.qualifier != null ? ' (${ingredient.qualifier})' : '')),
      subtitle: Text(ingredient.unit.toDisplayString(ingredient.quantity)),
    );
  }
}
