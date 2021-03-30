import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/main_app_scaffold.dart';
import 'package:projectquiche/model/recipe.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/routing/app_route_path.dart';
import 'package:projectquiche/routing/inner_router_delegate.dart';
import 'package:projectquiche/screens/authenticate.dart';
import 'package:projectquiche/screens/recipe.dart';
import 'package:projectquiche/screens/recipe_input.dart';
import 'package:projectquiche/services/firebase/analytics_keys.dart';
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

    // safePrint("currentConfiguration: $result");

    return result;
  }

  // Return a navigator, configured to match the current app state
  @override
  Widget build(BuildContext context) {
    // TODO select??
    bool isAuthenticated = appModel.isFirebaseSignedIn;
    Recipe? currentRecipe = appModel.currentRecipe;
    bool isCreatingOrEditing = appModel.isCreatingOrEditing;

    return Navigator(
      key: navigatorKey,
      pages: [
        // Sign in flow
        if (isAuthenticated == false) ...[
          MaterialPage(
            // TODO analytics reports this even when it's shown 1ms
            // The way to fix is probably to hold a Splash for some time
            name: MyAnalytics.pageAuthenticate,
            key: ValueKey("AuthenticatePage"),
            child: AuthenticateScreen(),
          ),
        ]

        // Main flow
        else ...[
          // Main scaffold with drawer
          MaterialPage(
            // Trick: set the name both here and in the inner router so that
            // it's reported on inner push/pop as well as global pop
            name: appModel.recipesHomeIndex == 0
                ? MyAnalytics.pageMyRecipes
                : MyAnalytics.pageExploreRecipes,
            key: ValueKey("MainScaffold"),
            child: MainAppScaffold(),
          ),

          // View page + Edit page
          if (currentRecipe != null) ...[
            MaterialPage(
                name: MyAnalytics.pageViewRecipe,
                key: ValueKey(currentRecipe),
                child: RecipeScreen(currentRecipe)),
            if (isCreatingOrEditing)
              MaterialPage(
                  name: MyAnalytics.pageEditRecipe,
                  key: ValueKey("$currentRecipe-edit"),
                  child: EditRecipeScreen(currentRecipe)),

            // Create recipe page
          ] else if (isCreatingOrEditing) ...[
            MaterialPage(
              name: MyAnalytics.pageCreateRecipe,
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
      observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics())],
    );
  }

  @override
  Future<void> setInitialRoutePath(AppRoutePath initialPath) async {
    // safePrint("setInitialRoutePath: $initialPath");

    await setNewRoutePath(initialPath);
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    safePrint("setNewRoutePath: $path");

    if (path is RecipeListRoutePath) {
      appModel.goToRecipeList(path);
    } else if (path is RecipeRoutePath) {
      appModel.goToRecipe(path);
    }
  }
}
