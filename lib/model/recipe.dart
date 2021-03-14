import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String? id;
  final String? name;
  final String? ingredients;
  final String? steps;
  final String? tips;

  const Recipe({this.id, this.name, this.ingredients, this.steps, this.tips});

  toJson() {
    return {
      "name": name,
      "ingredients": ingredients,
      "steps": steps,
      "tips": tips,
    };
  }

  static Recipe fromDocument(DocumentSnapshot doc) {
    var data = doc.data()!;
    return Recipe(
      id: doc.id,
      name: data["name"],
      ingredients: data["ingredients"],
      steps: data["steps"],
      tips: data["tips"],
    );
  }
}
