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
  var _recipeName = "";
  var _recipeIngredients = "";
  var _recipeSteps = "";
  var _recipeTips = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("New recipe")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Name"),
                onChanged: (text) {
                  _recipeName = text;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Ingredients"),
                keyboardType: TextInputType.multiline,
                onChanged: (text) {
                  _recipeIngredients = text;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Steps"),
                keyboardType: TextInputType.multiline,
                onChanged: (text) {
                  _recipeSteps = text;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Tips"),
                keyboardType: TextInputType.multiline,
                onChanged: (text) {
                  _recipeTips = text;
                },
              ),
              ElevatedButton(
                child: Text('Add'),
                onPressed: _postNewRecipe,
              )
            ],
          ),
        ));
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
