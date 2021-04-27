import 'package:flutter/material.dart';
import 'package:projectquiche/models/app_user.dart';
import 'package:projectquiche/models/group.dart';
import 'package:projectquiche/models/recipe.dart';
import 'package:projectquiche/routing/app_route_path.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';

/// Hold the global app state. Things like: "is user signed in" and "what is
/// the current page".
/// When this grows, it might make sense to break up into multiple models, e.g.
/// one for global app state (AppModel) and one for content state (RecipesModel).
class AppModel extends ChangeNotifier {
  final FirebaseService _firebase;

  AppModel(this._firebase) {
    _firebase.addListener(() {
      if (_firebase.firebaseUser == null) {
        // Reset state on log out
        _reset();
      }

      // When FirebaseService notifies its listeners, AppModel will notify theirs
      notifyListeners();
    });
  }

  // ===========================================================================
  // INIT + AUTH
  // ===========================================================================

  /// The app has bootstrapped when it has received the first callback for a
  /// Firebase user? plus -- if user != null -- the first callback for an AppUser?
  bool get hasBootstrapped => _firebase.hasBootstrapped;

  AppUser? get currentUser => _firebase.appUser;

  void _reset() {
    _currentRecipe = null;
    _isWritingRecipe = false;
    _currentSpace = AppSpace.myRecipes;

    // Do not notifyListeners, the caller of reset() takes care of it
  }

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  AppSpace get currentSpace => _currentSpace;
  AppSpace _currentSpace = AppSpace.myRecipes;

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

  void goToRecipeList(AppSpaceRoutePath path) {
    _currentRecipe = null;
    _isWritingRecipe = false;
    _currentSpace = path.space;

    notifyListeners();
  }

  void goToRecipe(RecipeRoutePath path) {
    _currentRecipe = null; // path.recipeId; // TODO lookup by ID!
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
}
