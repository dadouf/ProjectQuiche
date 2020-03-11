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
          return RecipeListItem(recipe);
        }).toList(),
      ),
    );
  }
}

class RecipeListItem extends StatelessWidget {
  final Recipe recipe;

  RecipeListItem(this.recipe);

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
            children: []
              ..add(_makeIngredientsList())
              ..addAll(_makeStepList())),
      );
    }));
  }

  Iterable<PreparationStepListItem> _makeStepList() {
    var i = 1;
    return recipe.steps.map((step) {
      return PreparationStepListItem(i++, step);
    });
  }

  Widget _makeIngredientsList() {
    return Container(
        height: 90,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: recipe.ingredients
              .map((ingredient) => IngredientListItem(ingredient))
              .toList(),
        ));
  }
}

class IngredientListItem extends StatelessWidget {
  final Ingredient ingredient;

  IngredientListItem(this.ingredient);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 90,
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Text(
                  ingredient.product +
                      (ingredient.qualifier != null
                          ? ' (${ingredient.qualifier})'
                          : ''),
                  style: TextStyle(fontSize: 18),
                ),
                Text(ingredient.unit.toDisplayString(ingredient.quantity))
              ],
            )));
  }
}

class PreparationStepListItem extends StatelessWidget {
  final int index;
  final PreparationStep step;

  PreparationStepListItem(this.index, this.step);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
          '#$index ${step.title != null ? step.title : ''}\n${step.instructions}'),
    );
  }
}
