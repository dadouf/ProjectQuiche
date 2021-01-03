import 'dart:convert';
import 'dart:developer';

class Ingredient {
  final String qualifier;
  final String product;
  final num quantity;
  final QuantityUnit unit;

  Ingredient(this.product, this.quantity, this.unit, {this.qualifier});

  toJson() {}
}

class QuantityUnit {
  static const item = QuantityUnit('', '');
  static const tbsp = QuantityUnit('tbsp', 'tbsp');
  static const cup = QuantityUnit('cup', 'cups');
  static const pinch = QuantityUnit('pinch', 'pinches');

  final String singular;
  final String plural;

  const QuantityUnit(this.singular, this.plural);

  String toDisplayString(num quantity) {
    if (quantity > 1) {
      return '$quantity $plural';
    } else {
      return '$quantity $singular';
    }
  }

  static QuantityUnit from(String s) {
    if (s == "tbsp") {
      return tbsp;
    } else if (s == "cup") {
      return cup;
    } else if (s == "pinch") {
      return pinch;
    } else {
      return item;
    }
  }
}

class IngredientsConverter extends Converter<List, Set<Ingredient>> {
  @override
  Set<Ingredient> convert(List<dynamic> input) {
    if (input == null) {
      log("No ingredients for recipe");
      return {};
    }

    return input
        .map((item) => Ingredient(
            item['name'], item['qty'], QuantityUnit.from(item['unit'])))
        .toSet();
  }
}
