class Recipe {
  final String name;
  final Set<Ingredient> ingredients;
  final List<PreparationStep> steps;

  const Recipe({this.name, this.ingredients, this.steps});
}

class Ingredient {
  final String qualifier;
  final String product;
  final int quantity;
  final QuantityUnit unit;

  Ingredient(this.product, this.quantity, this.unit, {this.qualifier});
}

class QuantityUnit {
  static const item = QuantityUnit('', '');
  static const tbsp = QuantityUnit('tbsp', 'tbsp');
  static const cup = QuantityUnit('cup', 'cups');
  static const pinch = QuantityUnit('pinch', 'pinches');

  final String singular;
  final String plural;

  const QuantityUnit(this.singular, this.plural);

  String toDisplayString(int quantity) {
    if (quantity > 1) {
      return '$quantity $plural';
    } else {
      return '$quantity $singular';
    }
  }
}

class PreparationStep {
  final String title;
  final String instructions;

  const PreparationStep({this.title, this.instructions});
}
