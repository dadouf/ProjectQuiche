import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/main_app_scaffold.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/models/app_user.dart';
import 'package:projectquiche/models/group.dart';
import 'package:projectquiche/models/recipe.dart';
import 'package:projectquiche/routing/app_route_path.dart';
import 'package:projectquiche/routing/inner_router_delegate.dart';
import 'package:projectquiche/screens/authenticate.dart';
import 'package:projectquiche/screens/group.dart';
import 'package:projectquiche/screens/group_input.dart';
import 'package:projectquiche/screens/recipe.dart';
import 'package:projectquiche/screens/recipe_input.dart';
import 'package:projectquiche/screens/splash.dart';
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

    if (!appModel.hasBootstrapped) {
      result = null;
    } else if (appModel.currentUser == null) {
      result = AuthRoutePath();
    } else {
      if (appModel.currentRecipe == null) {
        if (appModel.isWritingRecipe) {
          result = RecipeRoutePath.create();
        } else {
          result = AppSpaceRoutePath(space: appModel.currentSpace);
        }
      } else {
        if (appModel.isWritingRecipe) {
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
    // TODO select to avoid rebuilds?
    bool hasBootstrapped = appModel.hasBootstrapped;
    AppUser? user = appModel.currentUser;

    Recipe? currentRecipe = appModel.currentRecipe;
    bool isWritingRecipe = appModel.isWritingRecipe;

    Group? currentGroup = appModel.currentGroup;
    bool isWritingGroup = appModel.isWritingGroup;

    return Navigator(
      key: navigatorKey,
      pages: [
        if (!hasBootstrapped) ...[
          MaterialPage(
            name: MyAnalytics.pageSplash,
            key: ValueKey("Splash"),
            child: SplashScreen(),
          )
        ]

        // Sign in flow
        else if (user == null) ...[
          MaterialPage(
            // TODO analytics reports this even when it's shown 1ms
            // The way to fix is probably to hold a Splash for some time
            name: MyAnalytics.pageAuthenticate,
            key: ValueKey("Authenticate"),
            child: AuthenticateScreen(),
          ),
        ]

        // Main flow
        else ...[
          // Main scaffold with drawer
          MaterialPage(
            // Trick: set the name both here and in the inner router so that
            // it's reported on inner push/pop as well as global pop
            name: MyAnalytics.pageFromSpace(appModel.currentSpace),
            key: ValueKey("MainScaffold"),
            child: MainAppScaffold(),
          ),

          //
          // RECIPE
          //
          if (currentRecipe != null) ...[
            // View
            MaterialPage(
                name: MyAnalytics.pageViewRecipe,
                key: ValueKey(currentRecipe),
                child: RecipeScreen(currentRecipe)),

            // Edit
            if (isWritingRecipe)
              MaterialPage(
                  name: MyAnalytics.pageEditRecipe,
                  key: ValueKey("$currentRecipe-edit"),
                  child: EditRecipeScreen(currentRecipe)),
          ] else if (isWritingRecipe) ...[
            // Create
            MaterialPage(
              name: MyAnalytics.pageCreateRecipe,
              key: ValueKey("NewRecipePage"),
              child: CreateRecipeScreen(),
            ),
          ],

          //
          // GROUP
          //
          if (currentGroup != null) ...[
            // View
            MaterialPage(
                name: MyAnalytics.pageViewGroup,
                key: ValueKey(currentGroup),
                child: GroupScreen(currentGroup)),

            // Edit
            if (isWritingGroup)
              MaterialPage(
                  name: MyAnalytics.pageEditRecipe,
                  key: ValueKey("$currentGroup-edit"),
                  child: EditGroupScreen(currentGroup)),
          ] else if (isWritingGroup) ...[
            // Create
            MaterialPage(
              name: MyAnalytics.pageCreateRecipe,
              key: ValueKey("NewGroupPage"),
              child: CreateGroupScreen(),
            ),
          ],
        ],
      ],
      onPopPage: (route, result) {
        safePrint("AppRouter: onPopPage");

        if (!route.didPop(result)) {
          // The route handled it internally, do nothing else
          return false;
        }

        if (appModel.isWritingRecipe) {
          appModel.cancelWritingRecipe();
          return true;
        }

        if (appModel.currentRecipe != null) {
          appModel.cancelViewingRecipe();
          return true;
        }

        if (appModel.isWritingGroup) {
          appModel.cancelWritingGroup();
          return true;
        }

        if (appModel.currentGroup != null) {
          appModel.cancelViewingGroup();
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

    if (path is AppSpaceRoutePath) {
      appModel.goToRecipeList(path);
    } else if (path is RecipeRoutePath) {
      appModel.goToRecipe(path);
    }
  }
}
