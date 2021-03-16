import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/data/MyFirestore.dart';
import 'package:projectquiche/model/recipe.dart';

class EditRecipePage extends StatefulWidget {
  const EditRecipePage(this.recipe, {Key? key}) : super(key: key);
  final Recipe recipe;

  @override
  _EditRecipePageState createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  String? _recipeName;
  String? _recipeIngredients;
  String? _recipeSteps;
  String? _recipeTips;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("New recipe"),
          actions: [
            IconButton(icon: Icon(Icons.save), onPressed: _postEditRecipe)
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: "Info"),
              Tab(text: "Ingredients"),
              Tab(text: "Steps"),
              Tab(text: "Tips"),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TabBarView(
            children: [
              TextFormField(
                initialValue: widget.recipe.name,
                decoration: InputDecoration(labelText: "Name"),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  _recipeName = text;
                },
              ),
              TextFormField(
                initialValue: widget.recipe.ingredients,
                // Ingredients
                decoration:
                    InputDecoration(hintText: "- 20g butter\n- 4 eggs\n..."),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  _recipeIngredients = text;
                },
                expands: true,
                maxLines: null,
                minLines: null,
              ),
              TextFormField(
                initialValue: widget.recipe.steps,
                decoration: InputDecoration(
                    hintText: "1. Preheat oven to 220°C\n2. Cut stuff\n..."),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  _recipeSteps = text;
                },
                expands: true,
                maxLines: null,
                minLines: null,
              ),
              TextFormField(
                initialValue: widget.recipe.tips,
                decoration: InputDecoration(
                    hintText: "Serve with mixed greens or mash potato.\n..."),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  _recipeTips = text;
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

  void _postEditRecipe() {
    MyFirestore.recipes().doc(widget.recipe.id).update({
      MyFirestore.fieldName: _recipeName ?? widget.recipe.name,
      MyFirestore.fieldIngredients:
          _recipeIngredients ?? widget.recipe.ingredients,
      MyFirestore.fieldSteps: _recipeSteps ?? widget.recipe.steps,
      MyFirestore.fieldTips: _recipeTips ?? widget.recipe.tips,
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
  }
}
