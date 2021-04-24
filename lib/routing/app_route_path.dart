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
  final bool isWriting;

  const RecipeRoutePath.view(String this.recipeId) : isWriting = false;

  const RecipeRoutePath.edit(String this.recipeId) : isWriting = true;

  const RecipeRoutePath.create()
      : recipeId = null,
        isWriting = true;

  @override
  String toString() =>
      "RecipeRoutePath{recipeId: '$recipeId', isWriting: $isWriting}";
}

class GroupRoutePath extends AppRoutePath {
  final String? groupId;
  final bool isWriting;

  const GroupRoutePath.view(String this.groupId) : isWriting = false;

  const GroupRoutePath.edit(String this.groupId) : isWriting = true;

  const GroupRoutePath.create()
      : groupId = null,
        isWriting = true;

  @override
  String toString() =>
      "GroupRoutePath{groupId: '$groupId', isWriting: $isWriting}";
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
