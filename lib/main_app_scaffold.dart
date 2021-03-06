import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/routing/app_route_path.dart';
import 'package:projectquiche/routing/inner_router_delegate.dart';
import 'package:projectquiche/screens/my_profile.dart';
import 'package:projectquiche/ui/app_theme.dart';
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

    // Claim priority if this is the top screen TODO this condition is error prone
    if (appModel.currentRecipe == null &&
        !appModel.isWritingRecipe &&
        appModel.currentGroup == null &&
        !appModel.isWritingGroup) {
      _backButtonDispatcher?.takePriority();
    } else {
      Router.of(context).backButtonDispatcher?.takePriority();
    }

    return Scaffold(
        appBar: appModel.currentSpace == AppSpace.myProfile
            ? PreferredSize(
                child: HeroHeader(),
                preferredSize: Size.fromHeight(kToolbarHeight * 3),
              )
            : null,
        bottomNavigationBar: Container(
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SpaceTab(
                space: AppSpace.myRecipes,
                icon: Icons.book,
                title: AppLocalizations.of(context)!.myRecipes,
              ),
              SpaceTab(
                space: AppSpace.exploreRecipes,
                icon: Icons.explore,
                title: AppLocalizations.of(context)!.exploreRecipes,
              ),
              SpaceTab(
                space: AppSpace.groups,
                icon: Icons.group,
                title: AppLocalizations.of(context)!.groups,
              ),
              SpaceTab(
                space: AppSpace.myProfile,
                icon: Icons.person,
                title: AppLocalizations.of(context)!.myProfile,
              ),
            ],
          ),
        ),
        body: Router(
          routerDelegate: _routerDelegate,
          backButtonDispatcher: _backButtonDispatcher,
        ),
        floatingActionButton: appModel.currentSpace == AppSpace.myRecipes
            ? FloatingActionButton.extended(
                label: Text(AppLocalizations.of(context)!.recipe_add_button),
                icon: Icon(Icons.edit_outlined),
                onPressed: _addRecipe,
              )
            : appModel.currentSpace == AppSpace.groups
                ? FloatingActionButton.extended(
          label: Text(AppLocalizations.of(context)!.group_add_button),
                    icon: Icon(Icons.add),
                    onPressed: _addGroup,
                  )
                : null);
  }

  void _addRecipe() {
    context.read<AppModel>().startCreatingRecipe();
  }

  void _addGroup() {
    context.read<AppModel>().startCreatingGroup();
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

    return Expanded(
      child: SizedBox(
        height: 75,
        child: Theme(
          data: AppTheme.boldColorScheme.toTheme(),
          child: TextButton(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: appModel.currentSpace == space
                      ? null
                      : AppColors.disabledNavIcon,
                ),
                if (appModel.currentSpace == space)
                  Text(
                    title,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
            onPressed: () => appModel.currentSpace = space,
          ),
        ),
      ),
    );
  }
}
