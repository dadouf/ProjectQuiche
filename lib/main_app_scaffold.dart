import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:projectquiche/model/recipe.dart';
import 'package:projectquiche/pages/explore_recipes.dart';
import 'package:projectquiche/pages/my_recipes.dart';
import 'package:projectquiche/pages/recipe.dart';
import 'package:projectquiche/pages/recipe_input.dart';
import 'package:projectquiche/routing/app_routes.dart';

class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold(this.observer, {Key? key}) : super(key: key);

  final FirebaseAnalyticsObserver observer;

  @override
  _MainAppScaffoldState createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> with RouteAware {
  late List<Widget> _pages;
  final List<String> _pageTitles = [
    "My Recipes",
    "Explore Recipes",
  ];
  final List<String> _pageRoutes = [
    AppRoutes.myRecipes,
    AppRoutes.exploreRecipes,
  ];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pages = [
      MyRecipesPage(onRecipeTap: _openRecipe),
      ExploreRecipesPage(onRecipeTap: _openRecipe),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const paddingValue = 16.0;
    const padding = const EdgeInsets.all(paddingValue);
    return Scaffold(
        appBar: AppBar(
          title: Text(_pageTitles[_currentPage]),
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
                            setState(() {
                              _currentPage = 0;
                            });
                            _closeDrawer();
                          },
                        ),
                        ListTile(
                          title: Text("Explore Recipes"),
                          onTap: () {
                            setState(() {
                              _currentPage = 1;
                            });
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
        body: _pages[_currentPage],
        floatingActionButton: _currentPage == 0
            ? FloatingActionButton(
                child: Icon(Icons.plus_one),
                onPressed: _addRecipe,
              )
            : null);
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  // TODO factor: this is shared code with Explore recipes
  void _openRecipe(Recipe recipe) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => RecipePage(recipe),
      settings: RouteSettings(name: AppRoutes.viewRecipe(recipe)),
    ));
  }

  void _addRecipe() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => NewRecipePage(),
      settings: RouteSettings(name: AppRoutes.newRecipe),
    ));
  }

  void _logout() {
    final Function errorHandler = (error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to sign out: $error"),
      ));
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    };

    FirebaseAuth.instance
        .signOut() // this is enough to go back to Login screen
        .catchError(errorHandler);

    GoogleSignIn()
        .signOut() // this is needed in order to PROMPT user again
        .catchError(errorHandler);

    // ... causes callback in main.app because auth state changed
  }

  // ---
  // All the code below is to report analytics events when changing drawer page
  // See https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_analytics/firebase_analytics/example/lib/tabs_page.dart
  // ---

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      // Official example is outdated, keep an eye on it... Meanwhile casting works.
      widget.observer.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    widget.observer.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _sendCurrentTabToAnalytics();
  }

  @override
  void didPopNext() {
    _sendCurrentTabToAnalytics();
  }

  void _sendCurrentTabToAnalytics() {
    widget.observer.analytics.setCurrentScreen(
      screenName: _pageRoutes[_currentPage],
    );
  }
}
