import 'package:firebase_analytics/observer.dart';
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
  final FirebaseAnalyticsObserver observer;

  const MainAppScaffold({required this.observer, Key? key}) : super(key: key);

  @override
  _MainAppScaffoldState createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> with RouteAware {
  final List<String> _pageTitles = [
    "My Recipes",
    "Explore Recipes",
  ];

  late InnerRouterDelegate _routerDelegate;
  late ChildBackButtonDispatcher _backButtonDispatcher;

  @override
  void initState() {
    super.initState();
    _routerDelegate = InnerRouterDelegate(context.read<AppModel>());
  }

  @override
  void didUpdateWidget(covariant MainAppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _routerDelegate.appModel = context.read<AppModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Defer back button dispatching to the child router
    _backButtonDispatcher = Router.of(context)
        .backButtonDispatcher!
        .createChildBackButtonDispatcher();
  }

  @override
  Widget build(BuildContext context) {
    // Claim priority, If there are parallel sub router, you will need
    // to pick which one should take priority;
    _backButtonDispatcher.takePriority();

    // TODO is it good practice to factor:
    // AppModel appModel = context.read<AppModel>() and use it in this method?

    const paddingValue = 16.0;
    const padding = const EdgeInsets.all(paddingValue);
    return Scaffold(
        appBar: AppBar(
          title: Text(_pageTitles[context.read<AppModel>().recipesHomeIndex]),
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
                            // No need for setState because appModel will notify listeners
                            context.read<AppModel>().recipesHomeIndex = 0;
                            _closeDrawer();
                          },
                        ),
                        ListTile(
                          title: Text("Explore Recipes"),
                          onTap: () {
                            // No need for setState because appModel will notify listeners
                            context.read<AppModel>().recipesHomeIndex = 1;
                            _closeDrawer();
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
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
                                  "$packageName\nVersion $version+$buildNumber",
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
        floatingActionButton: context.read<AppModel>().recipesHomeIndex == 0
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

// ---
// All the code below is to report analytics events when changing drawer page
// See https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_analytics/firebase_analytics/example/lib/tabs_page.dart
// ---

// @override
// void didChangeDependencies() {
//   super.didChangeDependencies();
//   var modalRoute = ModalRoute.of(context);
//   if (modalRoute is PageRoute) {
//     // Official example is outdated, keep an eye on it... Meanwhile casting works.
//     widget.observer.subscribe(this, modalRoute);
//   }
// }
//
// @override
// void dispose() {
//   widget.observer.unsubscribe(this);
//   super.dispose();
// }
//
// @override
// void didPush() {
//   _sendCurrentTabToAnalytics();
// }
//
// @override
// void didPopNext() {
//   _sendCurrentTabToAnalytics();
// }
//
// void _sendCurrentTabToAnalytics() {
//   // widget.observer.analytics.setCurrentScreen(
//   //   screenName: _pageRoutes[_currentPage],
//   // );
// }
}
