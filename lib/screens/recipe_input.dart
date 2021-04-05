import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/model/recipe.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:provider/provider.dart';

class CreateRecipeScreen extends StatelessWidget {
  const CreateRecipeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RecipeInputPage(
      title: AppLocalizations.of(context)!.addRecipe,
      onRecipeSave: ({required name, ingredients, steps, tips}) async {
        try {
          await MyFirestore.recipes().add({
            MyFirestore.fieldName: name,
            MyFirestore.fieldIngredients: ingredients,
            MyFirestore.fieldSteps: steps,
            MyFirestore.fieldTips: tips,
            MyFirestore.fieldCreatedBy: {
              MyFirestore.fieldUid: FirebaseAuth.instance.currentUser?.uid,
              MyFirestore.fieldName:
                  FirebaseAuth.instance.currentUser?.displayName
            },
            MyFirestore.fieldCreationDate: DateTime.now(),
            MyFirestore.fieldMovedToBin: false,
            MyFirestore.fieldVisibility: "public",
          });

          context.read<AppModel>().completeEditing();

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.addRecipe_success),
          ));
        } on Exception catch (exception, trace) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                AppLocalizations.of(context)!.addRecipe_failure(exception)),
          ));
          context.read<FirebaseService>().recordError(exception, trace);
        }
      },
    );
  }
}

class EditRecipeScreen extends StatelessWidget {
  final Recipe recipe;

  const EditRecipeScreen(this.recipe, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RecipeInputPage(
      title: AppLocalizations.of(context)!.editRecipe,
      initialRecipe: recipe,
      onRecipeSave: ({required name, ingredients, steps, tips}) async {
        try {
          await MyFirestore.recipes().doc(recipe.id).update({
            MyFirestore.fieldName: name,
            MyFirestore.fieldIngredients: ingredients,
            MyFirestore.fieldSteps: steps,
            MyFirestore.fieldTips: tips,
          });

          context.read<AppModel>().completeEditing();

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.editRecipe_success),
          ));
          // FIXME the context is wrong here, I should show

        } on Exception catch (exception, trace) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                AppLocalizations.of(context)!.editRecipe_failure(exception)),
          ));
          context.read<FirebaseService>().recordError(exception, trace);
        }
      },
    );
  }
}

class RecipeInputPage extends StatefulWidget {
  final String title;
  final Recipe? initialRecipe;
  final void Function({
    required String name,
    required String? ingredients,
    required String? steps,
    required String? tips,
  }) onRecipeSave;

  const RecipeInputPage(
      {required this.title,
      this.initialRecipe,
      required this.onRecipeSave,
      Key? key})
      : super(key: key);

  @override
  _RecipeInputPageState createState() => _RecipeInputPageState();
}

class _RecipeInputPageState extends State<RecipeInputPage>
    with SingleTickerProviderStateMixin {
  // Note: right now 1 tab = 1 field, but this will change

  late List<Tab> _tabs = [];

  late TextEditingController _recipeName;
  late TextEditingController _recipeIngredients;
  late TextEditingController _recipeSteps;
  late TextEditingController _recipeTips;

  late TabController _tabController;
  late List<FocusNode> _focusNodes;

  final _nameKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();

    _recipeName = TextEditingController(text: widget.initialRecipe?.name);
    _recipeIngredients =
        TextEditingController(text: widget.initialRecipe?.ingredients);
    _recipeSteps = TextEditingController(text: widget.initialRecipe?.steps);
    _recipeTips = TextEditingController(text: widget.initialRecipe?.tips);

    _focusNodes = [FocusNode(), FocusNode(), FocusNode(), FocusNode()];

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabControllerEvent);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabControllerEvent);
    _tabController.dispose();

    _focusNodes.forEach((element) {
      element.dispose();
    });

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _tabs = [
      Tab(text: AppLocalizations.of(context)!.info),
      Tab(text: AppLocalizations.of(context)!.ingredients),
      Tab(text: AppLocalizations.of(context)!.steps),
      Tab(text: AppLocalizations.of(context)!.tips),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _onSavePressed)
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            TextFormField(
              key: _nameKey,
              focusNode: _focusNodes[0],
              controller: _recipeName,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.name),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (_validateName()) {
                  return null;
                } else {
                  return AppLocalizations.of(context)!.required;
                }
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            TextFormField(
              focusNode: _focusNodes[1],
              controller: _recipeIngredients,
              decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.ingredients_hint),
              textCapitalization: TextCapitalization.sentences,
              expands: true,
              maxLines: null,
              minLines: null,
            ),
            TextFormField(
              focusNode: _focusNodes[2],
              controller: _recipeSteps,
              decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.steps_hint),
              textCapitalization: TextCapitalization.sentences,
              expands: true,
              maxLines: null,
              minLines: null,
            ),
            TextFormField(
              focusNode: _focusNodes[3],
              controller: _recipeTips,
              decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.tips_hint),
              textCapitalization: TextCapitalization.sentences,
              expands: true,
              maxLines: null,
              minLines: null,
            ),
          ],
        ),
      ),
    );
  }

  void _onSavePressed() {
    if (_validateForm()) {
      context.read<FirebaseService>().logSave();

      widget.onRecipeSave(
        name: _recipeName.text,
        ingredients: _recipeIngredients.text,
        steps: _recipeSteps.text,
        tips: _recipeTips.text,
      );
    } else {
      // Animate to the tab that needs to change
      _tabController.animateTo(0);

      // Also display validation errors now in case we're already in the correct tab
      _displayValidationErrors();
    }
  }

  /// Note: validation of the full Form at once doesn't work because TabBarView
  /// doesn't really have all 4 children existing at once. Only the current one
  /// is attached, therefore validate() would only validate the currently
  /// displayed field.
  /// Instead, we manually validate the fields based on their state value.

  bool _validateForm() => _validateName();

  bool _validateName() => _recipeName.text.isNotEmpty;

  void _onTabControllerEvent() {
    // Upon settling...
    if (!_tabController.indexIsChanging) {
      // ... focus text field
      // FIXME small issue (maybe in Flutter): this always capitalizes even if there is a current text (Android-only apparently)
      _focusNodes[_tabController.index].requestFocus();

      // ... show validation errors
      if (_tabController.index == 0) {
        _displayValidationErrors();
      }
    }
  }

  void _displayValidationErrors() {
    _nameKey.currentState?.validate();
  }
}
