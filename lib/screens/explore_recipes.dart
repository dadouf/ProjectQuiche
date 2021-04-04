import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/model/recipe.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:provider/provider.dart';

class ExploreRecipesScreen extends StatefulWidget {
  ExploreRecipesScreen({required this.onRecipeTap, Key? key}) : super(key: key);

  final Function(Recipe recipe) onRecipeTap;

  @override
  _ExploreRecipesScreenState createState() => _ExploreRecipesScreenState();
}

class _ExploreRecipesScreenState extends State<ExploreRecipesScreen> {
  static const pageLimit = 20;

  Query _currentQuery = MyFirestore.recipes()
      // Non-deleted recipes. Note: can't do `moved_to_bin != true`
      .where(MyFirestore.fieldMovedToBin, isEqualTo: false)
      // Public recipes
      .where(MyFirestore.fieldVisibility, isEqualTo: "public")
      // Note: Can't filter out user's own recipes so we do it in the client later
      // Recent recipes
      .orderBy(MyFirestore.fieldCreationDate, descending: true)
      // Take 30
      .limit(pageLimit);

  /// The list of recipes to display. Null means we never got data.
  List<Recipe>? _loadedRecipes;

  Exception? _latestError;

  /// When non-null this signifies that there may be more data to load.
  /// It's set to null initially until we get the first page, and set to null
  /// again once we've received the last page.
  DocumentSnapshot? _lastDocument;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _fetchMoreRecipes();
  }

  @override
  Widget build(BuildContext context) {
    var loadedRecipes = _loadedRecipes
        ?.map((Recipe recipe) => ListTile(
              title: Text(recipe.name ?? "Untitled"),
              onTap: () => widget.onRecipeTap(recipe),
            ))
        .toList();

    if (loadedRecipes != null) {
      if (loadedRecipes.isNotEmpty) {
        // There's data
        if (_canLoadMore()) {
          if (_isLoading) {
            // We're loading more
            loadedRecipes.add(ListTile(
              title: Center(child: CircularProgressIndicator()),
            ));
          } else {
            // We'll be able to load more later
            loadedRecipes.add(ListTile(
              title: Center(
                child: Text(
                  "Load more",
                  style: TextStyle(
                    color: Color(0x60000000),
                    fontSize: 14,
                  ),
                ),
              ),
              onTap: () => _loadMore(false),
            ));
          }
        }

        return NotificationListener<ScrollEndNotification>(
          child: ListView(children: loadedRecipes),
          onNotification: (t) {
            var atBottomOfList = t.metrics.pixels == t.metrics.maxScrollExtent;
            if (atBottomOfList && _canLoadMore()) {
              _loadMore(true);
            }
            return false;
          },
        );
      } else {
        // There's no data
        return Center(child: Text("No recipes were found"));
      }
    } else if (_isLoading) {
      // First load in progress
      return Center(child: CircularProgressIndicator());
    } else {
      // First load completed with an error
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(16),
          child: Text(
            "Couldn't load screen. Please try again later.\n\nError: $_latestError",
            textAlign: TextAlign.center,
          ));
    }
  }

  bool _canLoadMore() => _lastDocument != null;

  Future<void> _fetchMoreRecipes({bool showSnackBar = false}) async {
    setState(() => _isLoading = true);

    try {
      var snapshot = await _currentQuery.get();

      var additionalDocs = snapshot.docs
          // Filter out user's own recipes (because we can't do it in the query)
          .where((element) =>
              element.data()![MyFirestore.fieldCreatedBy]
                  [MyFirestore.fieldUid] !=
              FirebaseAuth.instance.currentUser?.uid);

      // If the number of docs in the snapshot is < limit we already know we're reached the end
      var mayHaveMoreDocs = snapshot.docs.length == pageLimit;

      var additionalRecipes = additionalDocs
          .map((DocumentSnapshot document) => Recipe.fromDocument(document))
          .toList();

      setState(() {
        _loadedRecipes = (_loadedRecipes ?? []) + additionalRecipes;

        if (additionalDocs.isNotEmpty && mayHaveMoreDocs) {
          _lastDocument = additionalDocs.last;
        } else {
          _lastDocument = null; // will hide Load More button
        }
      });
    } on Exception catch (exception, trace) {
      context.read<FirebaseService>().recordError(exception, trace);

      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to load more: $exception"),
        ));
      }

      setState(() => _latestError = exception);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadMore(bool autoTriggered) {
    FirebaseService service = context.read<FirebaseService>();

    if (_canLoadMore()) {
      service.logLoadMore(_loadedRecipes?.length ?? 0, autoTriggered);

      _currentQuery = _currentQuery.startAfterDocument(_lastDocument!);
      _fetchMoreRecipes(showSnackBar: true);
    } else {
      // Not supposed to get here
      service.log("Tried to load more although it's impossible");
    }
  }
}
