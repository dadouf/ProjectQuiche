import 'package:flutter/material.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/routing/app_route_path.dart';
import 'package:projectquiche/routing/inner_router_delegate.dart';
import 'package:provider/provider.dart';

/// Parent of the main navigation UI (now: drawer, later: bottom nav bar)
/// as well as the current page accessed via that UI.
class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({Key? key}) : super(key: key);

  @override
  _MainAppScaffoldState createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> with RouteAware {
  final InnerRouterDelegate _routerDelegate = InnerRouterDelegate();
  late ChildBackButtonDispatcher? _backButtonDispatcher;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Defer back button dispatching to the child router
    _backButtonDispatcher = Router.of(context)
        .backButtonDispatcher
        ?.createChildBackButtonDispatcher();
  }

  @override
  Widget build(BuildContext context) {
    AppModel appModel = context.read<AppModel>();

    // Claim priority if this is the top screen
    if (appModel.currentRecipe == null && !appModel.isCreatingOrEditing) {
      _backButtonDispatcher?.takePriority();
    } else {
      Router.of(context).backButtonDispatcher?.takePriority();
    }

    return Scaffold(
        bottomNavigationBar: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: SpaceTab(
                  space: AppSpace.myRecipes,
                  icon: Icons.book,
                  title: "My Cookbook",
                ),
              ),
              Expanded(
                child: SpaceTab(
                  space: AppSpace.exploreRecipes,
                  icon: Icons.explore,
                  title: "Explore Recipes",
                ),
              ),
              Expanded(
                child: SpaceTab(
                  space: AppSpace.myProfile,
                  icon: Icons.person,
                  title: "My Profile",
                ),
              ),
            ],
          ),
        ),
        body: Router(
          routerDelegate: _routerDelegate,
          backButtonDispatcher: _backButtonDispatcher,
        ),
        floatingActionButton: appModel.currentSpace == AppSpace.myRecipes
            ? FloatingActionButton(
                child: Icon(Icons.edit_outlined),
                onPressed: _addRecipe,
              )
            : null);
  }

  void _addRecipe() {
    context.read<AppModel>().startCreatingRecipe();
  }
}

class SpaceTab extends StatelessWidget {
  const SpaceTab({
    Key? key,
    required this.space,
    required this.title,
    required this.icon,
  }) : super(key: key);

  final AppSpace space;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final appModel = context.read<AppModel>();

    return TextButton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: appModel.currentSpace == space ? null : Color(0xFF999999),
          ),
          if (appModel.currentSpace == space) Text(title),
        ],
      ),
      onPressed: () => appModel.currentSpace = space,
    );
  }
}
