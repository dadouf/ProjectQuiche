import 'package:projectquiche/model/recipe.dart';

class AppRoutes {
  AppRoutes._();

  static const String myRecipes = "/recipes/my";
  static const String exploreRecipes = "/recipes/explore";

  static const String newRecipe = "/recipes/my/new";

  static String viewRecipe(Recipe recipe) {
    // TODO this is a better route (more informative) but too precise for Analytics
    // return "/recipes/${recipe.id}";
    return "/recipes/view";
  }

  static String editRecipe(Recipe recipe) {
    // TODO this is a better route (more informative) but too precise for Analytics
    // return "/recipes/${recipe.id}/edit";
    return "/recipes/edit";
  }
}
