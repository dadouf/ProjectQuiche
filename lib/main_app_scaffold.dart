import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/routing/inner_router_delegate.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:provider/provider.dart';

/// Parent of the main navigation UI (now: drawer, later: bottom nav bar)
/// as well as the current page accessed via that UI.
class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({Key? key}) : super(key: key);

  @override
  _MainAppScaffoldState createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> with RouteAware {
  final List<String> _pageTitles = [
    "My Recipes",
    "Explore Recipes",
  ];

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

    const paddingValue = 16.0;
    const padding = const EdgeInsets.all(paddingValue);
    return Scaffold(
        appBar: AppBar(
          title: Text(_pageTitles[appModel.recipesHomeIndex]),
        ),
        drawer: Container(
          margin: EdgeInsets.only(right: 72),
          child: Material(
              color: Color(0xFF404040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: padding,
                                child: Text(
                                    "Connected as\n${FirebaseAuth.instance.currentUser?.email}"),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.logout),
                              onPressed: _logout,
                            ),
                          ],
                        ),
                        Divider(),
                        ListTile(
                          title: Text("My Recipes"),
                          onTap: () {
                            _closeDrawer();
                            appModel.recipesHomeIndex = 0;
                          },
                        ),
                        ListTile(
                          title: Text("Explore Recipes"),
                          onTap: () {
                            _closeDrawer();
                            appModel.recipesHomeIndex = 1;
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        String? appName = snapshot.data?.appName;
                        String? packageName = snapshot.data?.packageName;
                        String? version = snapshot.data?.version;
                        String? buildNumber = snapshot.data?.buildNumber;

                        const fadedColor = const Color(0x50FFFFFF);
                        return Padding(
                          padding: padding,
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                const EdgeInsets.only(right: paddingValue),
                                child: Icon(
                                  Icons.info_outline,
                                  color: fadedColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "$appName v$version+$buildNumber\n$packageName",
                                  style: TextStyle(color: fadedColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                ],
              )),
        ),
        body: Router(
          routerDelegate: _routerDelegate,
          backButtonDispatcher: _backButtonDispatcher,
        ),
        floatingActionButton: appModel.recipesHomeIndex == 0
            ? FloatingActionButton(
                child: Icon(Icons.plus_one),
                onPressed: _addRecipe,
              )
            : null);
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  void _addRecipe() {
    context.read<AppModel>().startCreatingRecipe();
  }

  Future<void> _logout() async {
    try {
      // This is enough to go back to Login screen
      await context.read<FirebaseService>().signOut();

      // This is needed in order to PROMPT user again
      await GoogleSignIn().signOut();

      // ... will cause AppModel update because FirebaseService.isSignedIn will change
    } on Exception catch (exception, stack) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to sign out: $exception"),
      ));
      context.read<FirebaseService>().recordError(exception, stack);
    }
  }
}
