import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyFirestore {
  MyFirestore._();

  static CollectionReference myRecipes() =>
      FirebaseFirestore.instance.collection(
          "/users_v1/${FirebaseAuth.instance.currentUser?.uid}/recipes_v1");

  static Query allRecipes() =>
      FirebaseFirestore.instance.collectionGroup("recipes_v1");

  static CollectionReference users() =>
      FirebaseFirestore.instance.collection("users_v1");

  static CollectionReference groups() =>
      FirebaseFirestore.instance.collection("groups_v0");

  // TODO scope field names so they can be found more easily

  //
  // Recipe
  //

  static const String fieldStatus = "status";
  static const String fieldVisibility = "visibility";
  static const String fieldCreator = "creator";
  static const String fieldName = "name";
  static const String fieldCreationDate = "creation_date";
  static const String fieldIngredients = "ingredients";
  static const String fieldSteps = "steps";
  static const String fieldTips = "tips";

  //
  // User
  //

  static const String fieldUserId = "user_id";
  static const String fieldUsername = "username";
  static const String fieldAvatarUrl = "avatar_url";
  static const String fieldAvatarSymbol = "avatar_symbol";
}
