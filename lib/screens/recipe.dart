import 'package:flutter/material.dart';
import 'package:projectquiche/model/models.dart';

class RecipePage extends StatelessWidget {
  final Recipe _recipe;

  const RecipePage(this._recipe, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
  }

  Widget _makeIngredientsCarousel() {
    var ingredients = _recipe.ingredients.toList();
    return Container(
        // There's no way around assigning a fixed height,
        // see https://stackoverflow.com/q/50155738/2291104
        height: 80,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ingredients.length,
            itemBuilder: (context, position) =>
                IngredientListItem(ingredients[position])));
  }
}

class IngredientListItem extends StatelessWidget {
  final Ingredient _ingredient;

  IngredientListItem(this._ingredient);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _ingredient.product +
                  (_ingredient.qualifier != null
                      ? ' (${_ingredient.qualifier})'
                      : ''),
              style: TextStyle(fontSize: 18),
            ),
            Text(_ingredient.unit.toDisplayString(_ingredient.quantity))
          ],
        ));
  }
}

class PreparationStepListItem extends StatelessWidget {
  final int _index;
  final PreparationStep _step;

  PreparationStepListItem(this._index, this._step);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
          '#$_index ${_step.title != null ? _step.title : ''}\n${_step.instructions}'),
    );
  }
}
