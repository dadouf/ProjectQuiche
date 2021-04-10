import 'package:flutter/material.dart';
import 'package:projectquiche/models/app_user.dart';
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
    // When FirebaseService notifies its listeners, AppModel will notify theirs
    _firebase.addListener(notifyListeners);
  }

  // ------------
  // Init + Auth
  // ------------

  /// The app has bootstrapped when it has received the first callback for a
  /// Firebase user? plus -- if user != null -- the first callback for an AppUser?
  bool get hasBootstrapped => _firebase.hasBootstrapped;

  AppUser? get currentUser => _firebase.appUser;

  // ----------
  // Navigation
  // ----------

  Recipe? get currentRecipe => _currentRecipe;
  Recipe? _currentRecipe;

  bool get isCreatingOrEditing => _isCreatingOrEditing;
  bool _isCreatingOrEditing = false;

  AppSpace get currentSpace => _currentSpace;
  AppSpace _currentSpace = AppSpace.myRecipes;

  set currentSpace(AppSpace value) {
    _currentSpace = value;
    notifyListeners();
  }

  void startCreatingRecipe() {
    _currentRecipe = null;
    _isCreatingOrEditing = true;
    notifyListeners();
  }

  void startViewingRecipe(Recipe recipe) {
    _currentRecipe = recipe;
    _isCreatingOrEditing = false;
    notifyListeners();
  }

  void startEditingRecipe(Recipe recipe) {
    _currentRecipe = recipe;
    _isCreatingOrEditing = true;
    notifyListeners();
  }

  void cancelCreatingOrEditingRecipe() {
    _isCreatingOrEditing = false;
    notifyListeners();
  }

  void cancelViewingRecipe() {
    _currentRecipe = null;
    notifyListeners();
  }

  void completeEditing() {
    _isCreatingOrEditing = false;

    // Until we find a way to update the Recipe page we've just edited,
    // go all the way back to Home.
    _currentRecipe = null;

    notifyListeners();
  }

  void goToRecipeList(AppSpaceRoutePath path) {
    _currentRecipe = null;
    _isCreatingOrEditing = false;
    _currentSpace = path.space;

    notifyListeners();
  }

  void goToRecipe(RecipeRoutePath path) {
    _currentRecipe = null; // path.recipeId; // TODO lookup by ID!
    _isCreatingOrEditing = path.isEditing;
    _currentSpace = AppSpace.exploreRecipes; // unknown

    notifyListeners();
  }
}
