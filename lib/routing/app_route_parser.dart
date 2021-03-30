import 'package:flutter/material.dart';
import 'package:projectquiche/routing/app_route_path.dart';
import 'package:projectquiche/utils/safe_print.dart';

class AppRouteParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    AppRoutePath? result;

    if (routeInformation.location != null) {
      final uri = Uri.parse(routeInformation.location!);

      if (uri.pathSegments.length == 0) {
        // /
        result = RecipeListRoutePath();
      } else if (uri.pathSegments[0] == 'recipes') {
        if (uri.pathSegments.length == 1) {
          // /recipes
          result = RecipeListRoutePath();
        } else {
          if (uri.pathSegments[1] == "my") {
            // /recipes/my
            result = RecipeListRoutePath(home: RecipesHome.my);
          } else if (uri.pathSegments[1] == "explore") {
            // /recipes/explore
            result = RecipeListRoutePath(home: RecipesHome.explore);
          } else if (uri.pathSegments[1] == "new") {
            // /recipes/new
            result = RecipeRoutePath.create();
          } else {
            String recipeId = uri.pathSegments[1];
            if (uri.pathSegments.length == 3 && uri.pathSegments[2] == "edit") {
              // /recipes/{id}/edit
              result = RecipeRoutePath.edit(recipeId);
            } else {
              // /recipes/{id}
              result = RecipeRoutePath.view(recipeId);
            }
          }
        }
      }
    }

    safePrint(
        "parseRouteInformation: ${routeInformation.toDebugString()} -> $result");

    return result ?? UnknownRoutePath();
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath path) {
    RouteInformation? result;

    if (path is RecipeRoutePath) {
      if (path.recipeId != null) {
        if (path.isEditing) {
          result = RouteInformation(location: "/recipes/${path.recipeId}/edit");
        } else {
          result = RouteInformation(location: "/recipes/${path.recipeId}");
        }
      } else {
        result = RouteInformation(location: "/recipes/new");
      }
    }

    if (path is RecipeListRoutePath) {
      result = RouteInformation(location: "/recipes/${path.home}");
    }

    if (path is AuthRoutePath) {
      result = RouteInformation(location: "/sign_in");
    }

    safePrint("restoreRouteInformation: $path -> ${result?.toDebugString()}");

    return result;
  }
}

extension Debug on RouteInformation {
  String toDebugString() {
    return "RouteInformation{location: '$location'}";
  }
}
