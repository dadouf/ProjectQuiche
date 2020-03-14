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
        body: ListView.builder(
            itemCount: _recipes.length,
            itemBuilder: (context, position) {
              return RecipeListItem(_recipes[position]);
            }));
  }
}

class RecipeListItem extends StatelessWidget {
  final Recipe _recipe;

  RecipeListItem(this._recipe);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_recipe.name),
      onTap: () => _openRecipe(context),
    );
  }

  void _openRecipe(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
          appBar: AppBar(title: Text(_recipe.name)),
          body: ListView.builder(
              itemCount: _recipe.steps.length + 1,
              itemBuilder: (context, position) {
                if (position == 0) {
                  return _makeIngredientsCarousel();
                } else {
                  return PreparationStepListItem(
                      position, _recipe.steps[position - 1]);
                }
              }));
    }));
  }

  Widget _makeIngredientsCarousel() {
    return Container(
        height: 90,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _recipe.ingredients
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
