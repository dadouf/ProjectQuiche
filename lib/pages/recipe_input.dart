import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/data/MyFirestore.dart';
import 'package:projectquiche/model/recipe.dart';

class NewRecipePage extends StatelessWidget {
  const NewRecipePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RecipeInputPage(
        title: "New recipe",
        onRecipeSave: ({required name, ingredients, steps, tips}) {
          MyFirestore.recipes().add({
            MyFirestore.fieldName: name,
            MyFirestore.fieldIngredients: ingredients,
            MyFirestore.fieldSteps: steps,
            MyFirestore.fieldTips: tips,
            MyFirestore.fieldCreatedBy: {
              MyFirestore.fieldUid: FirebaseAuth.instance.currentUser?.uid,
              MyFirestore.fieldName:
                  FirebaseAuth.instance.currentUser?.displayName
            },
            MyFirestore.fieldMovedToBin: false
          }).then((value) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("New recipe added")));
          }).catchError((error, stackTrace) {
            final reason = "Failed to add recipe";
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(reason)));
            FirebaseCrashlytics.instance
                .recordError(error, stackTrace, reason: reason);
          });

          Navigator.pop(context);
        });
  }
}

class EditRecipePage extends StatelessWidget {
  final Recipe recipe;

  const EditRecipePage(this.recipe, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RecipeInputPage(
      title: "Edit recipe",
      initialRecipe: recipe,
      onRecipeSave: ({required name, ingredients, steps, tips}) {
        MyFirestore.recipes().doc(recipe.id).update({
          MyFirestore.fieldName: name,
          MyFirestore.fieldIngredients: ingredients,
          MyFirestore.fieldSteps: steps,
          MyFirestore.fieldTips: tips,
        }).then((value) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Recipe edited")));
        }).catchError((error, stackTrace) {
          final reason = "Failed to edit recipe";
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(reason)));
          FirebaseCrashlytics.instance
              .recordError(error, stackTrace, reason: reason);
        });

        Navigator.pop(context);

        // FIXME recipe doesn't get updated in recipe page, until it does we go back all the way
        Navigator.pop(context);
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

  final _tabs = [
    Tab(text: "Info"),
    Tab(text: "Ingredients"),
    Tab(text: "Steps"),
    Tab(text: "Tips"),
  ];

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
              decoration: InputDecoration(labelText: "Name"),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (_validateName()) {
                  return null;
                } else {
                  return "Required";
                }
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            TextFormField(
              focusNode: _focusNodes[1],
              controller: _recipeIngredients,
              decoration:
                  InputDecoration(hintText: "- 20g butter\n- 4 eggs\n..."),
              textCapitalization: TextCapitalization.sentences,
              expands: true,
              maxLines: null,
              minLines: null,
            ),
            TextFormField(
              focusNode: _focusNodes[2],
              controller: _recipeSteps,
              decoration: InputDecoration(
                  hintText: "1. Preheat oven to 220°C\n2. Cut stuff\n..."),
              textCapitalization: TextCapitalization.sentences,
              expands: true,
              maxLines: null,
              minLines: null,
            ),
            TextFormField(
              focusNode: _focusNodes[3],
              controller: _recipeTips,
              decoration: InputDecoration(
                  hintText: "Serve with mixed greens or mash potato.\n..."),
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
      widget.onRecipeSave(
        name: _recipeName.text,
        ingredients: _recipeIngredients.text,
        steps: _recipeSteps.text,
        tips: _recipeTips.text,
      );
    } else {
      // Animate to the tab that needs to change
      _tabController.animateTo(0);

      // FIXME if we're already on the right tab then validation doesn't appear
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

      // ... call validate() -- this is only to show errors
      if (_tabController.index == 0) {
        _nameKey.currentState?.validate();
      }
    }
  }
}
