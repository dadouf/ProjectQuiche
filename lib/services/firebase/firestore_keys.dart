import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyFirestore {
  MyFirestore._();

  // TODO consider using withConverter but this requires to always deal with
  // full objects (no partial updates)

  static CollectionReference<Map<String, dynamic>> myRecipes() =>
      FirebaseFirestore.instance.collection(
          "/users_v1/${FirebaseAuth.instance.currentUser?.uid}/recipes_v1");

  /*.withConverter(
        fromFirestore: (snapshot, _) => Recipe.fromDocument(snapshot),
        toFirestore: (Recipe recipe, _) => recipe.toJson(),
      );*/

  // No converter available :(( see: https://github.com/FirebaseExtended/flutterfire/pull/6015
  static Query<Map<String, dynamic>> allRecipes() =>
      FirebaseFirestore.instance.collectionGroup("recipes_v1");

  static CollectionReference<Map<String, dynamic>> users() =>
      FirebaseFirestore.instance.collection("users_v1");

  /*.withConverter(
            fromFirestore: (snapshot, _) => AppUser.fromDocument(snapshot),
            toFirestore: (AppUser user, _) => user.toJson(),
          );*/

  static CollectionReference<Map<String, dynamic>> groups() =>
      FirebaseFirestore.instance.collection("groups_v0");

  /*.withConverter(
            fromFirestore: (snapshot, _) => Group.fromDocument(snapshot),
            toFirestore: (Group group, _) => group.toJson(),
          );*/

  // TODO scope field names so they can be found more easily

  //
  // Reused fields
  //

  static const String fieldCreator = "creator";
  static const String fieldCreationDate = "creation_date";
  static const String fieldStatus = "status";

  //
  // Recipe
  //

  static const String fieldIsPublic = "is_public";
  static const String fieldSharedWithGroups = "shared_with_groups";
  static const String fieldName = "name";
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

  //
  // Group
  //
  static const String fieldCoverUrl = "cover_url";
  static const String fieldMembers = "members";
  static const String fieldMembersInfo = "members_info";
  static const String fieldAcceptsNewMembers = "accepts_new_members";
}
