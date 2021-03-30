import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/model/recipe.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:projectquiche/widgets/single_child_draggable_scroll_view.dart';
import 'package:provider/provider.dart';

class ExploreRecipesScreen extends StatefulWidget {
  ExploreRecipesScreen({required this.onRecipeTap, Key? key}) : super(key: key);

  final Function(Recipe recipe) onRecipeTap;

  @override
  _ExploreRecipesScreenState createState() => _ExploreRecipesScreenState();
}

class _ExploreRecipesScreenState extends State<ExploreRecipesScreen> {
  Query _currentQuery = MyFirestore.recipes()
      // Non-deleted recipes. Note: can't do `moved_to_bin != true`
      .where(MyFirestore.fieldMovedToBin, isEqualTo: false)
      // Public recipes
      .where(MyFirestore.fieldVisibility, isEqualTo: "public")
      // Note: Can't filter out user's own recipes so we do it in the client later
      // Recent recipes
      .orderBy(MyFirestore.fieldCreationDate, descending: true)
      // Take 30
      .limit(30);

  // TODO add cursor

  /// Until the first load completes we show a global progress bar in the center
  /// of the view. Next loads will simply show a [RefreshIndicator].
  bool _firstLoadCompleted = false;

  /// The list of recipes to display. Null means we never got data.
  List<Recipe>? _data;

  Exception? _latestError;

  @override
  void initState() {
    super.initState();

    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    // FIXME (minor): refresh is hard to cancel by gesture, i.e. drag down then up
    return LayoutBuilder(
        builder: (context, constraints) => RefreshIndicator(
              onRefresh: () => _refreshData(showSnackBar: true),
              child: buildListOrPlaceholder(constraints),
            ));
  }

  Widget buildListOrPlaceholder(BoxConstraints parentConstraints) {
    var data = _data;

    if (data != null) {
      if (data.isNotEmpty) {
        return ListView(
            children: data
                .map((Recipe recipe) => ListTile(
                      title: Text(recipe.name ?? "Untitled"),
                      onTap: () {
                        widget.onRecipeTap(recipe);
                      },
                    ))
                .toList());
      } else {
        return SingleChildDraggableScrollView(
            child: Center(child: Text("No recipes were found")),
            parentConstraints: parentConstraints);
      }
    } else if (!_firstLoadCompleted) {
      // Do not make this draggable: it's already loading
      return Center(child: CircularProgressIndicator());
    } else {
      return SingleChildDraggableScrollView(
          child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16),
              child: Text(
                "Couldn't load screen. Please try again later.\n\nError: $_latestError",
                textAlign: TextAlign.center,
              )),
          parentConstraints: parentConstraints);
    }
  }

  Future<void> _refreshData({bool showSnackBar = false}) async {
    try {
      var snapshot = await _currentQuery.get();
      setState(() {
        _data = snapshot.docs
            .map((DocumentSnapshot document) => Recipe.fromDocument(document))
            // Filter out user's own recipes (because we can't do it in the query)
            .where((element) =>
                element.createdByUid != FirebaseAuth.instance.currentUser?.uid)
            .toList();

        _firstLoadCompleted = true;
      });
    } on Exception catch (exception, trace) {
      context.read<FirebaseService>().recordError(exception, trace);

      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to refresh: $exception"),
        ));
      }

      setState(() {
        _firstLoadCompleted = true;
        _latestError = exception;
      });
    }
  }
}
