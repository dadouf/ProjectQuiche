import 'package:cloud_firestore/cloud_firestore.dart';

class MyFirestore {
  MyFirestore._();

  static CollectionReference recipes() =>
      FirebaseFirestore.instance.collection("recipes_v0");

  static const String fieldMovedToBin = "moved_to_bin";
  static const String fieldCreatedBy = "created_by";
  static const String fieldUid = "uid";
  static const String fieldName = "name";
  static const String fieldIngredients = "ingredients";
  static const String fieldSteps = "steps";
  static const String fieldTips = "tips";
}
