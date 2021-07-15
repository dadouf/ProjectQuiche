import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/data/app_user.dart';
import 'package:projectquiche/data/group.dart';
import 'package:projectquiche/data/recipe.dart';
import 'package:projectquiche/routing/app_route_parser.dart';
import 'package:projectquiche/routing/app_route_path.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';

/// Hold the global app state. Things like: "is user signed in" and "what is
/// the current page".
///
/// The pattern enforced here is that the AppModel is standalone and does not
/// listen to any dependency. Instead, other widgets and services update the
/// AppModel, which in turns notifies its listeners.
class AppModel extends ChangeNotifier {
  // ===========================================================================
  // INIT + AUTH

  /// The app has bootstrapped when it has received the first callback for a
  /// Firebase user? plus -- if user != null -- the first callback for an AppUser?
  bool get hasBootstrapped => _hasBootstrapped;
  bool _hasBootstrapped = false;

  /// User in the Firebase sense. You should almost never have to refer to this
  /// because in most cases, after fully logging in there is a non-null [user]
  /// that supersedes this.
  User? get firebaseUser => _firebaseUser;
  User? _firebaseUser;

  AppUser? get user => _user;
  AppUser? _user;

  void setUser(User? firebaseUser, AppUser? user) {
    _hasBootstrapped = true;
    _firebaseUser = firebaseUser;
    _user = user;

    if (user == null) {
      // Also reset the app state: next user will see the Home screen after login
      _currentRecipe = null;
      _currentGroup = null;
      _isWritingRecipe = false;
      _isWritingGroup = false;
      _currentSpace = AppSpace.myRecipes;
    }

    notifyListeners();
  }

  // ===========================================================================
  // NAVIGATION

  AppSpace get currentSpace => _currentSpace;
  AppSpace _currentSpace = AppSpace.myRecipes;

  void followDeepLink(Uri? deepLink) {
    final path = AppRouteParser().parseDeepLink(deepLink);

    if (path != null) {
      followPath(path);
    }
  }

  void followPath(AppRoutePath path) {
    if (path is AppSpaceRoutePath) {
      _goToRecipeList(path);
    } else if (path is RecipeRoutePath) {
      _goToRecipe(path);
    } else if (path is GroupRoutePath) {
      _goToGroup(path);
    }
  }

  set currentSpace(AppSpace value) {
    _currentSpace = value;
    notifyListeners();
  }

  // -------
  // Recipes
  // -------

  Recipe? get currentRecipe => _currentRecipe;
  Recipe? _currentRecipe;

  /// Writing = Creating | Updating
  bool get isWritingRecipe => _isWritingRecipe;
  bool _isWritingRecipe = false;

  void startCreatingRecipe() {
    _currentRecipe = null;
    _isWritingRecipe = true;
    notifyListeners();
  }

  void startViewingRecipe(Recipe recipe) {
    _currentRecipe = recipe;
    _isWritingRecipe = false;
    notifyListeners();
  }

  void startEditingRecipe(Recipe recipe) {
    _currentRecipe = recipe;
    _isWritingRecipe = true;
    notifyListeners();
  }

  void cancelWritingRecipe() {
    _isWritingRecipe = false;
    notifyListeners();
  }

  void cancelViewingRecipe() {
    _currentRecipe = null;
    notifyListeners();
  }

  void completeWritingRecipe() {
    _isWritingRecipe = false;

    // Until we find a way to update the Recipe page we've just edited,
    // go all the way back to Home.
    _currentRecipe = null;

    notifyListeners();
  }

  void _goToRecipeList(AppSpaceRoutePath path) {
    _currentRecipe = null;
    _isWritingRecipe = false;
    _currentSpace = path.space;

    notifyListeners();
  }

  Future<void> _goToRecipe(RecipeRoutePath path) async {
    final recipeDoc = await MyFirestore.myRecipes().doc(path.recipeId).get();
    final recipe = Recipe.fromDocument(recipeDoc);
    // Comment diable cela marche-t-il avant que je log in?

    _currentRecipe = recipe;
    _isWritingRecipe = path.isWriting;
    _currentSpace = AppSpace.exploreRecipes; // unknown

    notifyListeners();
  }

  // ------
  // Groups
  // ------

  Group? get currentGroup => _currentGroup;
  Group? _currentGroup;

  /// Writing = Creating | Updating
  bool get isWritingGroup => _isWritingGroup;
  bool _isWritingGroup = false;

  void startCreatingGroup() {
    _currentGroup = null;
    _isWritingGroup = true;
    notifyListeners();
  }

  void startViewingGroup(Group group) {
    _currentGroup = group;
    _isWritingGroup = false;
    notifyListeners();
  }

  void cancelWritingGroup() {
    _isWritingGroup = false;
    notifyListeners();
  }

  void cancelViewingGroup() {
    _currentGroup = null;
    notifyListeners();
  }

  void completeWritingGroup() {
    _isWritingGroup = false;

    // Until we find a way to update the Group page we've just edited,
    // go all the way back to Home.
    _currentGroup = null;

    notifyListeners();
  }

  Future<void> _goToGroup(GroupRoutePath path) async {
    final groupDoc = await MyFirestore.groups().doc(path.groupId).get();
    final group = Group.fromDocument(groupDoc);
    // Comment diable cela marche-t-il avant que je log in? :thinking_face:

    _currentGroup = group;
    _isWritingGroup = path.isWriting;
    _currentSpace = AppSpace.groups;

    notifyListeners();
  }
}
