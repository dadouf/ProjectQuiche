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
      final parts = uri.pathSegments;

      if (parts.length == 0) {
        // /
        result = AppRoutePath.initial();
      } else if (parts.length == 1) {
        if (parts[0] == "recipes") {
          // /recipes
          result = AppSpaceRoutePath();
        } else if (parts[0] == "me") {
          // /me
          result = AppSpaceRoutePath(space: AppSpace.myProfile);
        }
      } else if (parts.length == 2) {
        if (parts[0] == "recipes" && parts[1] == "my") {
          // recipes/my
          result = AppSpaceRoutePath(space: AppSpace.myRecipes);
        } else if (parts[0] == "recipes" && parts[1] == "explore") {
          // recipes/explore
          result = AppSpaceRoutePath(space: AppSpace.exploreRecipes);
        } else if (parts[0] == "recipes") {
          final recipeId = parts[1];
          result = RecipeRoutePath.view(recipeId);
        }
      } else if (parts.length == 3) {
        if (parts[0] == "recipes" && parts[2] == "edit") {
          final recipeId = parts[1];
          result = RecipeRoutePath.edit(recipeId);
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

    if (path is AppSpaceRoutePath) {
      // FIXME this is broken
      result = RouteInformation(location: _pathFromSpace(path.space));
    }

    if (path is AuthRoutePath) {
      result = RouteInformation(location: "/sign_in");
    }

    safePrint("restoreRouteInformation: $path -> ${result?.toDebugString()}");

    return result;
  }

  static String _pathFromSpace(AppSpace currentSpace) {
    switch (currentSpace) {
      case AppSpace.myRecipes:
        return "/recipes/my";
      case AppSpace.exploreRecipes:
        return "/recipes/explore";
      case AppSpace.myProfile:
        return "/me";
      case AppSpace.groups:
        return "/groups";
    }
  }
}

extension Debug on RouteInformation {
  String toDebugString() {
    return "RouteInformation{location: '$location'}";
  }
}
