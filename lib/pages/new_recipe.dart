import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/data/MyFirestore.dart';

class NewRecipePage extends StatefulWidget {
  const NewRecipePage({Key? key}) : super(key: key);

  @override
  _NewRecipePageState createState() => _NewRecipePageState();
}

class _NewRecipePageState extends State<NewRecipePage> {
  String _recipeName = "Untitled";
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
            IconButton(icon: Icon(Icons.save), onPressed: _postNewRecipe)
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
                decoration: InputDecoration(labelText: "Name"),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  _recipeName = text;
                },
              ),
              TextFormField(
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

  void _postNewRecipe() {
    MyFirestore.recipes().add({
      MyFirestore.fieldName: _recipeName,
      MyFirestore.fieldIngredients: _recipeIngredients,
      MyFirestore.fieldSteps: _recipeSteps,
      MyFirestore.fieldTips: _recipeTips,
      MyFirestore.fieldCreatedBy: {
        MyFirestore.fieldUid: FirebaseAuth.instance.currentUser?.uid,
        MyFirestore.fieldName: FirebaseAuth.instance.currentUser?.displayName
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
  }
}
