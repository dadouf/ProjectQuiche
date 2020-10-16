import 'dart:convert';

import 'ingredient.dart';
import 'preparation_step.dart';

class Recipe {
  final String id;
  final String name;
  final Set<Ingredient> ingredients;
  final List<PreparationStep> steps;

  const Recipe({this.id, this.name, this.ingredients, this.steps});
}

class RecipesConverter extends Converter<Map, List<Recipe>> {
  final _ingredientsConverter = IngredientsConverter();
  final _stepsConverter = PreparationStepsConverter();

  @override
  List<Recipe> convert(Map<dynamic, dynamic> input) {
    return input.keys
        .map((key) => new Recipe(
            id: key,
            name: input[key]['name'],
            ingredients:
                _ingredientsConverter.convert(input[key]['ingredients']),
            steps: _stepsConverter.convert(input[key]['steps'])))
        .toList();
  }
}
