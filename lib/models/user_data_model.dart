import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/data/app_user.dart';
import 'package:projectquiche/data/group.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:projectquiche/utils/safe_print.dart';

/// Holds an AppUser's Recipes and Groups.
/// This continuously listens for changes.
class UserDataModel extends ChangeNotifier {
  final FirebaseService firebaseService;

  // List<Recipe> _recipes = [];
  List<Group> groups = []; // TODO protect write
  // FIXME why can I see groups from other users??

  // StreamSubscription<QuerySnapshot>? _recipesSubscription;
  StreamSubscription<QuerySnapshot>? _groupsSubscription;

  AppUser? _appUser;

  UserDataModel(AppModel appModel, this.firebaseService) {
    appModel.addListener(() {
      if (_appUser != appModel.currentUser) {
        _stopListening();
        groups = [];
        safePrint("User changed: cleared groups");

        if (appModel.currentUser != null) {
          _startListening();
        }

        _appUser = appModel.currentUser;
      }
    });
  }

  void _startListening() {
    // _recipesSubscription = MyFirestore.myRecipes()
    //     .where(MyFirestore.fieldStatus, isEqualTo: "active")
    //     .where(MyFirestore.fieldUserId,
    //         isEqualTo: FirebaseAuth.instance.currentUser?.uid)
    //     .orderBy(MyFirestore.fieldName)
    //     .snapshots()
    //     .listen((snapshot) {
    //   _recipes = snapshot.docs
    //       .map((DocumentSnapshot doc) => Recipe.fromDocument(doc))
    //       .toList();
    // });

    safePrint(
        "Listening for groups, where members arrayContains: ${_appUser?.userId}");

    _groupsSubscription = MyFirestore.groups()
        .where("members", arrayContains: _appUser?.userId)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      final List<Group> incomingGroups = [];
      snapshot.docs.forEach((doc) {
        // Protect against future data model changes
        try {
          incomingGroups.add(Group.fromDocument(doc));
        } catch (e, stackTrace) {
          firebaseService.recordError(e, stackTrace);
        }
      });

      safePrint(
          "Receiving a new Groups snapshot: ${snapshot.docs.length} docs -> ${incomingGroups.length} valid groups");

      groups = incomingGroups;
      notifyListeners();
    });
  }

  void _stopListening() {
    _groupsSubscription?.cancel();
    _groupsSubscription = null;
  }
}
