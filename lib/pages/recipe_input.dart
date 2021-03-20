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
        onRecipeSave: (name, ingredients, steps, tips) {
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
        onRecipeSave: (name, ingredients, steps, tips) {
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
        });
  }
}

class RecipeInputPage extends StatefulWidget {
  final String title;
  final Recipe? initialRecipe;
  final void Function(
          String name, String? ingredients, String? steps, String? tips)
      onRecipeSave;

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
  final _formKey = GlobalKey<FormState>();

  final _tabs = [
    Tab(text: "Info"),
    Tab(text: "Ingredients"),
    Tab(text: "Steps"),
    Tab(text: "Tips"),
  ];

  String? _recipeName;
  String? _recipeIngredients;
  String? _recipeSteps;
  String? _recipeTips;

  late TabController _tabController;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _recipeName = widget.initialRecipe?.name;
    _recipeIngredients = widget.initialRecipe?.ingredients;
    _recipeSteps = widget.initialRecipe?.steps;
    _recipeTips = widget.initialRecipe?.tips;

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
        child: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              TextFormField(
                focusNode: _focusNodes[0],
                initialValue: _recipeName,
                decoration: InputDecoration(labelText: "Name"),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  setState(() {
                    _recipeName = text;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Required";
                  } else {
                    return null;
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              TextFormField(
                focusNode: _focusNodes[1],
                initialValue: _recipeIngredients,
                decoration:
                    InputDecoration(hintText: "- 20g butter\n- 4 eggs\n..."),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  setState(() {
                    _recipeIngredients = text;
                  });
                },
                expands: true,
                maxLines: null,
                minLines: null,
              ),
              TextFormField(
                focusNode: _focusNodes[2],
                initialValue: _recipeSteps,
                decoration: InputDecoration(
                    hintText: "1. Preheat oven to 220°C\n2. Cut stuff\n..."),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  setState(() {
                    _recipeSteps = text;
                  });
                },
                expands: true,
                maxLines: null,
                minLines: null,
              ),
              TextFormField(
                focusNode: _focusNodes[3],
                initialValue: _recipeTips,
                decoration: InputDecoration(
                    hintText: "Serve with mixed greens or mash potato.\n..."),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  setState(() {
                    _recipeTips = text;
                  });
                },
                expands: true,
                maxLines: null,
                minLines: null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSavePressed() {
    if (_formKey.currentState?.validate() == true) {
      if (_recipeName == null || _recipeName!.isEmpty) {
        // FIXME this should not happen: find out what's wrong with the form validation
        FirebaseCrashlytics.instance.log("Failed to validate form properly");
        widget.onRecipeSave(
            "Untitled", _recipeIngredients, _recipeSteps, _recipeTips);
      } else {
        widget.onRecipeSave(
            _recipeName!, _recipeIngredients, _recipeSteps, _recipeTips);
      }
    } else {
      _tabController.animateTo(0);
    }
  }

  void _onTabControllerEvent() {
    // TODO is this okay: it gets called pretty much all the time
    _focusNodes[_tabController.index].requestFocus();
  }
}
