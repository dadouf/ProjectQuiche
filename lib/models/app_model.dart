import 'package:flutter/material.dart';
import 'package:projectquiche/model/recipe.dart';
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

  // -------
  // Startup
  // -------

  bool get hasBootstrapped => _hasBootstrapped;
  bool _hasBootstrapped = false;

  void onBootstrapComplete() {
    _hasBootstrapped = true;
    notifyListeners();
  }

  // ------------
  // Auth
  // ------------

  bool get isFirebaseSignedIn => _firebase.isSignedIn;

  // ----------
  // Navigation
  // ----------

  Recipe? get currentRecipe => _currentRecipe;
  Recipe? _currentRecipe;

  bool get isCreatingOrEditing => _isCreatingOrEditing;
  bool _isCreatingOrEditing = false;

  int get recipesHomeIndex => _recipesHomeIndex;
  int _recipesHomeIndex = 0;

  set recipesHomeIndex(int value) {
    _recipesHomeIndex = value;
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

  void goToRecipeList(RecipeListRoutePath path) {
    _currentRecipe = null;
    _isCreatingOrEditing = false;
    _recipesHomeIndex = path.home == RecipesHome.my ? 0 : 1;

    notifyListeners();
  }

  void goToRecipe(RecipeRoutePath path) {
    _currentRecipe = null; // path.recipeId; // TODO lookup by ID!
    _isCreatingOrEditing = path.isEditing;
    _recipesHomeIndex = 0; // unknown

    notifyListeners();
  }
}
