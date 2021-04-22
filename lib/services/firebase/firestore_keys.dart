import 'package:cloud_firestore/cloud_firestore.dart';

class MyFirestore {
  MyFirestore._();

  static CollectionReference recipes() =>
      FirebaseFirestore.instance.collection("recipes_v0");

  static CollectionReference users() =>
      FirebaseFirestore.instance.collection("users_v0");

  static CollectionReference groups() =>
      FirebaseFirestore.instance.collection("groups_v0");

  // TODO scope field names so they can be found more easily

  //
  // Recipe
  //

  static const String fieldStatus = "status";
  static const String fieldVisibility = "visibility";
  static const String fieldCreatedBy = "created_by";
  static const String fieldUid = "uid";
  static const String fieldName = "name";
  static const String fieldCreationDate = "creation_date";
  static const String fieldIngredients = "ingredients";
  static const String fieldSteps = "steps";
  static const String fieldTips = "tips";

  //
  // User
  //

  static const String fieldUsername = "username";
  static const String fieldAvatarUrl = "avatar_url";
  static const String fieldAvatarSymbol = "avatar_symbol";
}
