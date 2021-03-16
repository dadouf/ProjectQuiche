import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/data/MyFirestore.dart';
import 'package:projectquiche/model/recipe.dart';

class RecipePage extends StatelessWidget {
  final Recipe _recipe;

  const RecipePage(this._recipe, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    var defaultPadding = const EdgeInsets.all(16.0);

    List<Widget>? actions =
        _recipe.createdByUid == FirebaseAuth.instance.currentUser?.uid
            ? [
                IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _onEditButtonClicked(context)),
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _onDeleteButtonClicked(context)),
              ]
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe.name ?? "Untitled"),
        actions: actions,
      ),
      body: ListView(
        children: [
          Padding(
            padding: defaultPadding,
            child: Text("Created by ${getRecipeCreator()}"),
          ),
          Padding(
            padding: defaultPadding,
            child: Text("Ingredients", style: titleStyle),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(_recipe.ingredients ?? "None"),
          ),
          Padding(
            padding: defaultPadding,
            child: Text("Steps", style: titleStyle),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(_recipe.steps ?? "None"),
          ),
          Padding(
            padding: defaultPadding,
            child: Text("Tips", style: titleStyle),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(_recipe.tips ?? "None"),
          ),
        ],
      ),
    );
  }

  String getRecipeCreator() {
    if (_recipe.createdByUid == FirebaseAuth.instance.currentUser?.uid) {
      return "you";
    } else if (_recipe.createdByName != null) {
      // TODO how can I avoid having to cast to non-null
      return _recipe.createdByName!;
    } else if (_recipe.createdByUid != null) {
      return "User ${_recipe.createdByUid}";
    } else {
      return "someone";
    }
  }

  void _onEditButtonClicked(BuildContext context) {}

  /// Display a confirmation dialog
  void _onDeleteButtonClicked(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Move to bin"),
      onPressed: () => _deleteRecipe(context),
    );

    AlertDialog alert = AlertDialog(
      title: Text("Move to bin?"),
      content:
          Text("This recipe will no longer be visible by you or by anyone"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  /// Move the recipe to bin.
  /// Note: this is just setting a flag and not actually deleting the document,
  /// out of extra safety. TODO We will need an actual deletion strategy.
  void _deleteRecipe(BuildContext context) {
    MyFirestore.recipes()
        .doc(_recipe.id)
        .update({MyFirestore.FIELD_MOVED_TO_BIN: true})
        .then((value) => print("Recipe moved to bin"))
        .catchError((error, stackTrace) => FirebaseCrashlytics.instance
            .recordError(error, stackTrace,
                reason: "Failed to move recipe to bin"));

    Navigator.pop(context); // to close dialog
    Navigator.pop(context); // to close recipe
  }
}
