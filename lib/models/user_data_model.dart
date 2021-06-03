import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/data/app_user.dart';
import 'package:projectquiche/data/group.dart';
import 'package:projectquiche/data/recipe.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/services/bootstrap_service.dart';
import 'package:projectquiche/services/error_reporting_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:projectquiche/utils/safe_print.dart';

/// Holds an AppUser's Recipes and Groups.
/// This continuously listens for changes.
class UserDataModel extends ChangeNotifier {
  final BootstrapService firebaseService;
  final ErrorReportingService _errorReportingService;

  List<Recipe> recipes = [];
  List<Group> groups = []; // TODO protect write
  // FIXME why can I see groups from other users??

  StreamSubscription<QuerySnapshot>? _recipesSubscription;
  StreamSubscription<QuerySnapshot>? _groupsSubscription;

  AppUser? _appUser;

  UserDataModel(
      AppModel appModel, this.firebaseService, this._errorReportingService) {
    appModel.addListener(() {
      if (_appUser != appModel.user) {
        _stopListening();

        groups = [];
        safePrint("User changed: cleared groups");

        _appUser = appModel.user;
        if (appModel.user != null) {
          _startListening();
        }
      }
    });
  }

  void _startListening() {
    _startListeningForRecipes();
    _startListeningForGroups();
  }

  void _startListeningForRecipes() {
    safePrint("Listening for recipes, where userId=${_appUser?.userId}");

    _recipesSubscription = MyFirestore.myRecipes()
        .where(MyFirestore.fieldStatus, isEqualTo: "active")
        .where(MyFirestore.fieldUserId, isEqualTo: _appUser?.userId)
        .orderBy(MyFirestore.fieldName)
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
      final List<Recipe> incomingRecipes = [];
      snapshot.docs.forEach((doc) {
        // Protect against future data model changes
        try {
          incomingRecipes.add(Recipe.fromDocument(doc));
        } catch (e, stackTrace) {
          _errorReportingService.recordError(e, stackTrace);
        }
      });

      safePrint(
          "Receiving a new Recipes snapshot: ${snapshot.docs.length} docs -> ${incomingRecipes.length} valid recipes");

      recipes = incomingRecipes;
      notifyListeners();
    });
  }

  void _startListeningForGroups() {
    safePrint(
        "Listening for groups, where members arrayContains: ${_appUser?.userId}");

    _groupsSubscription = MyFirestore.groups()
        .where("members", arrayContains: _appUser?.userId)
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
      final List<Group> incomingGroups = [];
      snapshot.docs.forEach((doc) {
        // Protect against future data model changes
        try {
          incomingGroups.add(Group.fromDocument(doc));
        } catch (e, stackTrace) {
          _errorReportingService.recordError(e, stackTrace);
        }
      });

      safePrint(
          "Receiving a new Groups snapshot: ${snapshot.docs.length} docs -> ${incomingGroups.length} valid groups");

      groups = incomingGroups;
      notifyListeners();
    });
  }

  void _stopListening() {
    _recipesSubscription?.cancel();
    _recipesSubscription = null;

    _groupsSubscription?.cancel();
    _groupsSubscription = null;
  }
}
