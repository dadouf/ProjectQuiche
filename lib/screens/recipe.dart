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
  final Ingredient _ingredient;

  IngredientListItem(this._ingredient);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 90,
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
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
            )));
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
