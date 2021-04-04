import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/model/recipe.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:provider/provider.dart';

class RecipeScreen extends StatelessWidget {
  const RecipeScreen(this._recipe, {Key? key}) : super(key: key);
  final Recipe _recipe;

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
            child: Text(AppLocalizations.of(context)!
                .created_by(_getRecipeCreator(context))),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(
              AppLocalizations.of(context)!.ingredients,
              style: titleStyle,
            ),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(_recipe.ingredients ?? "None"),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(
              AppLocalizations.of(context)!.steps,
              style: titleStyle,
            ),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(_recipe.steps ?? "None"),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(AppLocalizations.of(context)!.tips, style: titleStyle),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(_recipe.tips ?? "None"),
          ),
        ],
      ),
    );
  }

  String _getRecipeCreator(BuildContext context) {
    if (_recipe.createdByUid == FirebaseAuth.instance.currentUser?.uid) {
      return AppLocalizations.of(context)!.me;
    } else if (_recipe.createdByName != null) {
      return _recipe.createdByName!;
    } else {
      return "User ${_recipe.createdByUid}";
    }
  }

  void _onEditButtonClicked(BuildContext context) {
    context.read<AppModel>().startEditingRecipe(_recipe);
  }

  /// Display a confirmation dialog
  void _onDeleteButtonClicked(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context); // to close dialog
      },
    );
    Widget continueButton = TextButton(
      child: Text("Move to bin"),
      onPressed: () {
        Navigator.pop(context); // to close dialog
        _deleteRecipe(context);
      },
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
  Future<void> _deleteRecipe(BuildContext context) async {
    final service = context.read<FirebaseService>();
    try {
      await MyFirestore.recipes()
          .doc(_recipe.id)
          .update({MyFirestore.fieldMovedToBin: true});

      service.logMoveToBin();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Recipe successfully moved to bin"),
      ));

      context.read<AppModel>().cancelViewingRecipe();
    } on Exception catch (exception, stack) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to move recipe to bin: $exception"),
      ));
      service.recordError(exception, stack);
    }
  }
}
