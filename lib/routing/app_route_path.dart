abstract class AppRoutePath {}

class RecipeListRoutePath extends AppRoutePath {
  final RecipesHome home;

  RecipeListRoutePath({this.home = RecipesHome.my});

  @override
  String toString() => "RecipeListRoutePath{home: $home}";
}

class RecipeRoutePath extends AppRoutePath {
  final String? recipeId;
  final bool isEditing;

  RecipeRoutePath.view(String this.recipeId) : isEditing = false;

  RecipeRoutePath.edit(String this.recipeId) : isEditing = true;

  RecipeRoutePath.create()
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

class RecipesHome {
  final String value;

  const RecipesHome._(this.value);

  static const my = const RecipesHome._("my");
  static const explore = const RecipesHome._("explore");

  @override
  String toString() => value;
}
