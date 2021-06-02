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
      final List<String> parts = uri.pathSegments;

      result = _routeToPath(parts);
    }

    safePrint(
        "parseRouteInformation: ${routeInformation.toDebugString()} -> $result");

    return result ?? UnknownRoutePath();
  }

  AppRoutePath? _routeToPath(List<String> parts) {
    if (parts.length == 0) {
      return AppRoutePath.initial();
    } else if (parts[0] == "recipes") {
      if (parts.length == 1) {
        return AppSpaceRoutePath(); // default
      } else if (parts[1] == "my") {
        return AppSpaceRoutePath(space: AppSpace.myProfile);
      } else if (parts[1] == "explore") {
        return AppSpaceRoutePath(space: AppSpace.exploreRecipes);
      } else if (parts[1] == "new") {
        return RecipeRoutePath.create();
      } else {
        final recipeId = parts[1];
        if (parts.length == 2) {
          return RecipeRoutePath.view(recipeId);
        } else if (parts[2] == "edit") {
          return RecipeRoutePath.edit(recipeId);
        }
      }
    } else if (parts[0] == "groups") {
      if (parts.length == 1) {
        return AppSpaceRoutePath(space: AppSpace.groups);
      } else if (parts[1] == "new") {
        return GroupRoutePath.create();
      } else {
        final groupId = parts[1];
        if (parts.length == 2) {
          return GroupRoutePath.view(groupId);
        } else if (parts[2] == "edit") {
          return GroupRoutePath.edit(groupId);
        }
      }
    } else if (parts[0] == "me") {
      return AppSpaceRoutePath(space: AppSpace.myProfile);
    }
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath path) {
    RouteInformation? result = _pathToRoute(path);

    safePrint("restoreRouteInformation: $path -> ${result?.toDebugString()}");

    return result;
  }

  RouteInformation? _pathToRoute(AppRoutePath path) {
    if (path is RecipeRoutePath) {
      if (path.recipeId != null) {
        if (path.isWriting) {
          return RouteInformation(location: "/recipes/${path.recipeId}/edit");
        } else {
          return RouteInformation(location: "/recipes/${path.recipeId}");
        }
      } else {
        return RouteInformation(location: "/recipes/new");
      }
    }

    if (path is GroupRoutePath) {
      if (path.groupId != null) {
        if (path.isWriting) {
          return RouteInformation(location: "/groups/${path.groupId}/edit");
        } else {
          return RouteInformation(location: "/groups/${path.groupId}");
        }
      } else {
        return RouteInformation(location: "/groups/new");
      }
    }

    if (path is AppSpaceRoutePath) {
      // FIXME this is broken
      return RouteInformation(location: _pathFromSpace(path.space));
    }

    if (path is AuthRoutePath) {
      return RouteInformation(location: "/sign_in");
    }

    return null;
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
