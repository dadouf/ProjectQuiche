import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/main_app_scaffold.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/routing/app_route_path.dart';
import 'package:projectquiche/routing/inner_router_delegate.dart';
import 'package:projectquiche/screens/authenticate.dart';
import 'package:projectquiche/screens/recipe.dart';
import 'package:projectquiche/screens/recipe_input.dart';
import 'package:projectquiche/utils/safe_print.dart';

/// Global app router.
/// See [InnerRouterDelegate]
class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  final AppModel appModel;

  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate(this.appModel)
      : navigatorKey = GlobalKey<NavigatorState>() {
    // Rebuild whenever any of our app state changes
    // When notifyListeners is called, it tells the Router to rebuild the RouterDelegate
    appModel.addListener(notifyListeners);
  }

  @override
  void dispose() {
    appModel.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  AppRoutePath? get currentConfiguration {
    AppRoutePath? result;

    if (!appModel.isFirebaseSignedIn) {
      result = AuthRoutePath();
    } else {
      if (appModel.currentRecipe == null) {
        if (appModel.isCreatingOrEditing) {
          result = RecipeRoutePath.create();
        } else if (appModel.recipesHomeIndex == 0) {
          result = RecipeListRoutePath(home: RecipesHome.my);
        } else if (appModel.recipesHomeIndex == 1) {
          result = RecipeListRoutePath(home: RecipesHome.explore);
        }
      } else {
        if (appModel.isCreatingOrEditing) {
          result = RecipeRoutePath.edit(appModel.currentRecipe!.id!);
        } else {
          result = RecipeRoutePath.view(appModel.currentRecipe!.id!);
        }
      }
    }

    safePrint("currentConfiguration: $result");

    return result;
  }

  // Return a navigator, configured to match the current app state
  @override
  Widget build(BuildContext context) {
    safePrint("AppRouterDelegate.build()");

    bool isAuthenticated = appModel.isFirebaseSignedIn;

    return Navigator(
      key: navigatorKey,
      pages: [
        // Sign in flow
        if (isAuthenticated == false) ...[
          MaterialPage(
            key: ValueKey("AuthenticatePage"),
            child: AuthenticateScreen(),
          ),
        ]

        // Main flow
        else ...[
          // Main scaffold with drawer
          MaterialPage(
              key: ValueKey("MainScaffold"),
              child: MainAppScaffold(
                  observer: FirebaseAnalyticsObserver(
                      analytics: FirebaseAnalytics()))),

          // View page + Edit page
          if (appModel.currentRecipe != null) ...[
            MaterialPage(
                key: ValueKey(appModel.currentRecipe!),
                child: RecipeScreen(appModel.currentRecipe!)),
            if (appModel.isCreatingOrEditing)
              MaterialPage(
                  key: ValueKey("${appModel.currentRecipe}-edit"),
                  child: EditRecipeScreen(appModel.currentRecipe!)),

            // Create recipe page
          ] else if (appModel.isCreatingOrEditing) ...[
            MaterialPage(
              key: ValueKey("NewRecipePage"),
              child: CreateRecipeScreen(),
            ),
          ]
        ],
      ],
      onPopPage: (route, result) {
        safePrint("AppRouter: onPopPage");

        if (!route.didPop(result)) {
          // The route handled it internally, do nothing else
          return false;
        }

        if (appModel.isCreatingOrEditing) {
          appModel.cancelCreatingOrEditingRecipe();
          return true;
        }

        if (appModel.currentRecipe != null) {
          appModel.cancelViewingRecipe();
          return true;
        }

        return false;
      },
    );
  }

  @override
  Future<void> setInitialRoutePath(AppRoutePath initialPath) async {
    safePrint("setInitialRoutePath: $initialPath");

    await setNewRoutePath(initialPath);
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    safePrint("setNewRoutePath: $path");

    // TODO set appmodel state here
  }
}
