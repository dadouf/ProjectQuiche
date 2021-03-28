import 'package:projectquiche/model/recipe.dart';

class AppRoutes {
  static const String myRecipes = "/recipes/my";
  static const String exploreRecipes = "/recipes/explore";

  static const String newRecipe = "/recipes/my/new";

  static String viewRecipe(Recipe recipe) => "/recipes/${recipe.id}";

  static String editRecipe(Recipe recipe) => "/recipes/${recipe.id}/edit";
}
