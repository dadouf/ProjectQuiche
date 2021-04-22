abstract class AppRoutePath {
  const AppRoutePath();

  static AppRoutePath initial() => AppSpaceRoutePath();
}

class AppSpaceRoutePath extends AppRoutePath {
  final AppSpace space;

  const AppSpaceRoutePath({this.space = AppSpace.myRecipes});

  @override
  String toString() => "AppSpaceRoutePath{home: $space}";
}

class RecipeRoutePath extends AppRoutePath {
  final String? recipeId;
  final bool isEditing;

  const RecipeRoutePath.view(String this.recipeId) : isEditing = false;

  const RecipeRoutePath.edit(String this.recipeId) : isEditing = true;

  const RecipeRoutePath.create()
      : recipeId = null,
        isEditing = true;

  @override
  String toString() =>
      "RecipeRoutePath{recipeId: '$recipeId', isEditing: $isEditing}";
}

class AuthRoutePath extends AppRoutePath {
  @override
  String toString() => "AuthRoutePath";
}

class UnknownRoutePath extends AppRoutePath {
  @override
  String toString() => "UnknownRoutePath";
}

enum AppSpace {
  myRecipes,
  exploreRecipes,
  myProfile,
  groups,
}
