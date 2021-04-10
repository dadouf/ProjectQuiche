import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/main_app_scaffold.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/models/recipe.dart';
import 'package:projectquiche/routing/app_route_path.dart';
import 'package:projectquiche/routing/app_router_delegate.dart';
import 'package:projectquiche/screens/explore_recipes.dart';
import 'package:projectquiche/screens/my_profile.dart';
import 'package:projectquiche/screens/my_recipes.dart';
import 'package:projectquiche/services/firebase/analytics_keys.dart';
import 'package:projectquiche/utils/safe_print.dart';
import 'package:provider/provider.dart';

/// Routes pages within the [MainAppScaffold].
/// See [AppRouterDelegate]
class InnerRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  InnerRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final AppSpace currentSpace =
        context.select((AppModel appModel) => appModel.currentSpace);

    return Navigator(
      key: navigatorKey,
      pages: [
        // Always include My Recipes page, so that the back button in other spaces
        // get us back to My Recipes
        InstantTransitionPage(
          name: MyAnalytics.pageMyRecipes,
          key: ValueKey("MyRecipesPage"),
          child: MyRecipesScreen(
            onRecipeTap: (recipe) => _handleRecipeTapped(context, recipe),
          ),
        ),

        // Maybe Explore page
        if (currentSpace == AppSpace.exploreRecipes) ...[
          InstantTransitionPage(
            name: MyAnalytics.pageExploreRecipes,
            key: ValueKey("ExploreRecipesPage"),
            child: ExploreRecipesScreen(
              onRecipeTap: (recipe) => _handleRecipeTapped(context, recipe),
            ),
          ),
        ] else if (currentSpace == AppSpace.myProfile) ...[
          InstantTransitionPage(
            name: MyAnalytics.pageMyProfile,
            key: ValueKey("MyProfilePage"),
            child: MyProfileScreen(),
          ),
        ]
      ],
      onPopPage: (route, result) {
        safePrint("InnerRouter: onPopPage");

        if (!route.didPop(result)) {
          // The route handled it internally, do nothing else
          return false;
        }

        final AppModel appModel = context.read<AppModel>();
        if (appModel.currentSpace != AppSpace.myRecipes) {
          appModel.currentSpace = AppSpace.myRecipes;
          return true;
        }

        return false;
      },
      observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics())],
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    // This is not required for inner router delegate because it does not
    // parse route
    assert(false);
  }

  void _handleRecipeTapped(BuildContext context, Recipe recipe) {
    context.read<AppModel>().startViewingRecipe(recipe);
    notifyListeners();
  }
}

/// Show the new page without any kind of transition: just replace
class InstantTransitionPage extends Page {
  final Widget child;

  InstantTransitionPage({
    required this.child,
    LocalKey? key,
    String? name,
    Object? arguments,
  }) : super(key: key, name: name, arguments: arguments);

  Route createRoute(BuildContext context) {
    // For some reason Duration.zero causes a Flutter exception
    const duration = Duration(milliseconds: 1);

    return PageRouteBuilder(
      settings: this,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, animation2) => child,
    );
  }
}
