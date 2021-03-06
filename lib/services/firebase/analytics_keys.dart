import 'package:projectquiche/routing/app_route_path.dart';

class MyAnalytics {
  MyAnalytics._();

  static const pageSplash = "Splash";
  static const pageAuthenticate = "Authenticate";

  static const pageMyRecipes = "MyRecipes";
  static const pageExploreRecipes = "ExploreRecipes";
  static const pageViewRecipe = "ViewRecipe";
  static const pageEditRecipe = "EditRecipe";
  static const pageCreateRecipe = "CreateRecipe";

  static const pageMyProfile = "Profile";

  static const pageGroups = "Groups";
  static const pageViewGroup = "ViewGroup";
  static const pageEditGroup = "EditGroup";
  static const pageCreateGroup = "CreateGroup";

  static String pageFromSpace(AppSpace currentSpace) {
    switch (currentSpace) {
      case AppSpace.myRecipes:
        return pageMyRecipes;
      case AppSpace.exploreRecipes:
        return pageExploreRecipes;
      case AppSpace.myProfile:
        return pageMyProfile;
      case AppSpace.groups:
        return pageGroups;
    }
  }
}
