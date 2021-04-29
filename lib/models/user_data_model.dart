import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/data/app_user.dart';
import 'package:projectquiche/data/group.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:projectquiche/utils/safe_print.dart';

/// Holds an AppUser's Recipes and Groups.
/// This continuously listens for changes.
class UserDataModel extends ChangeNotifier {
  // List<Recipe> _recipes = [];
  List<Group> groups = []; // TODO protect write

  // StreamSubscription<QuerySnapshot>? _recipesSubscription;
  StreamSubscription<QuerySnapshot>? _groupsSubscription;

  AppUser? _appUser;

  UserDataModel(AppModel appModel) {
    appModel.addListener(() {
      if (_appUser != appModel.currentUser) {
        _stopListening();

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

    _groupsSubscription = MyFirestore.groups()
        .where("members", arrayContains: _appUser?.userId)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      safePrint("Receiving a new Groups snapshot");
      groups = snapshot.docs.map((doc) => Group.fromDocument(doc)).toList();
      notifyListeners();
    });
  }

  void _stopListening() {
    _groupsSubscription?.cancel();
    _groupsSubscription = null;
  }
}
