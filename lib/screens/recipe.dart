import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/data/app_user.dart';
import 'package:projectquiche/data/recipe.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:projectquiche/ui/app_theme.dart';
import 'package:projectquiche/widgets/avatar.dart';
import 'package:provider/provider.dart';

class RecipeScreen extends StatelessWidget {
  const RecipeScreen(this._recipe, {Key? key}) : super(key: key);
  final Recipe _recipe;

  @override
  Widget build(BuildContext context) {
    var titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    var textStyle = TextStyle(fontSize: 16);
    var defaultPadding = const EdgeInsets.all(16.0);

    List<Widget>? actions =
        _recipe.creator?.userId == FirebaseAuth.instance.currentUser?.uid
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
            child: Text(
              AppLocalizations.of(context)!.ingredients,
              style: titleStyle,
            ),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(
              _recipe.ingredients ?? "None",
              style: textStyle,
            ),
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
            child: Text(
              _recipe.steps ?? "None",
              style: textStyle,
            ),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(AppLocalizations.of(context)!.tips, style: titleStyle),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(
              _recipe.tips ?? "None",
              style: textStyle,
            ),
          ),
          Divider(),
          Padding(
            padding: defaultPadding,
            child: _buildRecipeFooter(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeFooter(BuildContext context) {
    if (_recipe.creator?.userId == FirebaseAuth.instance.currentUser?.uid) {
      return _buildCreatedByOn(context, AppLocalizations.of(context)!.me,
          context.read<AppModel>().currentUser);
    } else {
      return _buildCreatedByOn(
          context, _recipe.creator?.username, _recipe.creator);
    }
  }

  Widget _buildCreatedByOn(BuildContext context, String? name, AppUser? user) {
    final textStyle = TextStyle(color: AppColors.hintOnLight, fontSize: 14);
    final displayName = name ?? AppLocalizations.of(context)!.unknownUser;
    final Widget text;

    if (_recipe.creationDate != null) {
      text = Text(
        AppLocalizations.of(context)!
            .created_by_on(displayName, _recipe.creationDate!),
        style: textStyle,
      );
    } else {
      text = Text(AppLocalizations.of(context)!.created_by(displayName),
          style: textStyle);
    }

    return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: user != null ? AvatarWidget(user: user, radius: 15) : null,
        title: text);
  }

  void _onEditButtonClicked(BuildContext context) {
    context.read<AppModel>().startEditingRecipe(_recipe);
  }

  /// Display a confirmation dialog
  void _onDeleteButtonClicked(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context)!.moveToBin_cancel),
      onPressed: () {
        Navigator.pop(context); // to close dialog
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context)!.moveToBin_confirm),
      onPressed: () {
        Navigator.pop(context); // to close dialog
        _deleteRecipe(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.moveToBin_title),
      content: Text(AppLocalizations.of(context)!.moveToBin_message),
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
      await MyFirestore.myRecipes()
          .doc(_recipe.id)
          .update({MyFirestore.fieldStatus: "binned"});

      service.logMoveToBin();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.moveToBin_success),
      ));

      context.read<AppModel>().cancelViewingRecipe();
    } catch (e, trace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.moveToBin_failure(e)),
      ));
      service.recordError(e, trace);
    }
  }
}
