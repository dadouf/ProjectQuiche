import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';

class Recipe {
  final String? id;
  final String? name;
  final String? ingredients;
  final String? steps;
  final String? tips;
  final String? createdByUid;
  final DateTime? creationDate;

  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.tips,
    required this.createdByUid,
    required this.creationDate,
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
      createdByUid: data[MyFirestore.fieldCreatedBy][MyFirestore.fieldUid],
      creationDate: data[MyFirestore.fieldCreationDate].toDate(),
    );
  }
}

/// Firestore is incapable of storing line breaks in String fields.
/// Instead, we store the "\n" as two literal characters. Upon receiving it,
/// we transform it into a multi-line string.
String? parseMultiLineString(String? str) => str?.replaceAll("\\n", "\n");
