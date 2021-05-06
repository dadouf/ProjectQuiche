import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectquiche/data/app_user.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';

class Recipe {
  final String? id;

  final AppUser? creator;
  final DateTime? creationDate;

  final String? name;
  final String? ingredients;
  final String? steps;
  final String? tips;

  final bool isPublic;
  final List<String> sharedWithGroups;

  const Recipe({
    this.id,
    this.creator,
    this.creationDate,
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.tips,
    required this.isPublic,
    required this.sharedWithGroups,
  });

  static Recipe fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data()!;
    return Recipe(
      id: doc.id,
      creator: AppUser.fromJson(data[MyFirestore.fieldCreator]),
      creationDate: data[MyFirestore.fieldCreationDate].toDate(),
      name: data[MyFirestore.fieldName],
      ingredients: parseMultiLineString(data[MyFirestore.fieldIngredients]),
      steps: parseMultiLineString(data[MyFirestore.fieldSteps]),
      tips: parseMultiLineString(data[MyFirestore.fieldTips]),
      isPublic: data[MyFirestore.fieldIsPublic],
      sharedWithGroups:
          List<String>.from(data[MyFirestore.fieldSharedWithGroups]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // TODO
    };
  }
}

/// Firestore is incapable of storing line breaks in String fields.
/// Instead, we store the "\n" as two literal characters. Upon receiving it,
/// we transform it into a multi-line string.
String? parseMultiLineString(String? str) => str?.replaceAll("\\n", "\n");

/// Recipe visibility from the user perspective. This is more tied to the UX
/// than to the data model, although the two are related.
enum PerceivedRecipeVisibility { private, groups, public }
