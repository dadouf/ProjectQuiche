import 'package:cloud_firestore/cloud_firestore.dart';

class MyFirestore {
  MyFirestore._();

  static CollectionReference recipes() =>
      FirebaseFirestore.instance.collection("recipes_v0");

  static const String FIELD_MOVED_TO_BIN = "moved_to_bin";
  static const String FIELD_CREATED_BY = "created_by";
  static const String FIELD_UID = "uid";
  static const String FIELD_NAME = "name";
  static const String FIELD_INGREDIENTS = "ingredients";
  static const String FIELD_STEPS = "steps";
  static const String FIELD_TIPS = "tips";
}
