import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectquiche/data/MyFirestore.dart';

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
      MyFirestore.FIELD_NAME: name,
      MyFirestore.FIELD_INGREDIENTS: ingredients,
      MyFirestore.FIELD_STEPS: steps,
      MyFirestore.FIELD_TIPS: tips,
    };
  }

  static Recipe fromDocument(DocumentSnapshot doc) {
    var data = doc.data()!;
    return Recipe(
      id: doc.id,
      name: data[MyFirestore.FIELD_NAME],
      ingredients: parseMultiLineString(data[MyFirestore.FIELD_INGREDIENTS]),
      steps: parseMultiLineString(data[MyFirestore.FIELD_STEPS]),
      tips: parseMultiLineString(data[MyFirestore.FIELD_TIPS]),
      createdByName: data[MyFirestore.FIELD_CREATED_BY][MyFirestore.FIELD_NAME],
      createdByUid: data[MyFirestore.FIELD_CREATED_BY][MyFirestore.FIELD_UID],
    );
  }
}

/// Firestore is incapable of storing line breaks in String fields.
/// Instead, we store the "\n" as two literal characters. Upon receiving it,
/// we transform it into a multi-line string.
String? parseMultiLineString(String? str) => str?.replaceAll("\\n", "\n");
