import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';

class Recipe {
  final String? id;
  final String? name;
  final String? ingredients;
  final String? steps;
  final String? tips;
  final String? createdByName;
  final String? createdByUid;

  const Recipe({
    this.id,
    this.name,
    this.ingredients,
    this.steps,
    this.tips,
    this.createdByName,
    this.createdByUid,
  });

  toJson() {
    return {
      MyFirestore.fieldName: name,
      MyFirestore.fieldIngredients: ingredients,
      MyFirestore.fieldSteps: steps,
      MyFirestore.fieldTips: tips,
    };
  }

  static Recipe fromDocument(DocumentSnapshot doc) {
    var data = doc.data()!;
    return Recipe(
      id: doc.id,
      name: data[MyFirestore.fieldName],
      ingredients: parseMultiLineString(data[MyFirestore.fieldIngredients]),
      steps: parseMultiLineString(data[MyFirestore.fieldSteps]),
      tips: parseMultiLineString(data[MyFirestore.fieldTips]),
      createdByName: data[MyFirestore.fieldCreatedBy][MyFirestore.fieldName],
      createdByUid: data[MyFirestore.fieldCreatedBy][MyFirestore.fieldUid],
    );
  }
}

/// Firestore is incapable of storing line breaks in String fields.
/// Instead, we store the "\n" as two literal characters. Upon receiving it,
/// we transform it into a multi-line string.
String? parseMultiLineString(String? str) => str?.replaceAll("\\n", "\n");
