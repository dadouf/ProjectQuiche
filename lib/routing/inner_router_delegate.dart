import 'package:flutter/material.dart';
import 'package:projectquiche/main_app_scaffold.dart';
import 'package:projectquiche/model/recipe.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/routing/app_route_path.dart';
import 'package:projectquiche/routing/app_router.dart';
import 'package:projectquiche/screens/explore_recipes.dart';
import 'package:projectquiche/screens/my_recipes.dart';
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
    final int recipesHomeIndex =
        context.select((AppModel appModel) => appModel.recipesHomeIndex);

    return Navigator(
      key: navigatorKey,
      pages: [
        // Always include My Recipes page: it's ONLY so that back button in
        // Explore gets back to My Recipes
        InstantTransitionPage(
          child: MyRecipesScreen(
            onRecipeTap: (recipe) => _handleRecipeTapped(context, recipe),
          ),
          key: ValueKey('MyRecipesPage'),
        ),

        // Maybe Explore page
        if (recipesHomeIndex == 1) ...[
          InstantTransitionPage(
            child: ExploreRecipesScreen(
              onRecipeTap: (recipe) => _handleRecipeTapped(context, recipe),
            ),
            key: ValueKey('ExploreRecipesPage'),
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
        if (appModel.recipesHomeIndex == 1) {
          appModel.recipesHomeIndex = 0;
          return true;
        }

        return false;
      },
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

  InstantTransitionPage({LocalKey? key, required this.child}) : super(key: key);

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
