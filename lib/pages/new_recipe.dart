import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewRecipePage extends StatefulWidget {
  const NewRecipePage({Key? key}) : super(key: key);

  @override
  _NewRecipePageState createState() => _NewRecipePageState();
}

class _NewRecipePageState extends State<NewRecipePage> {
  var _recipeName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("New recipe")),
        body: ListView(
          children: [
            TextField(
              onChanged: _onTextChanged,
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: _postNewRecipe,
            )
          ],
        ));
  }

  void _postNewRecipe() {
    CollectionReference recipes =
        FirebaseFirestore.instance.collection('recipes');

    recipes
        .add({
          'name': _recipeName,
          'created_by': FirebaseAuth.instance.currentUser?.uid,
        })
        .then((value) => print("Recipe Added"))
        .catchError((error) => print("Failed to add recipe: $error"));

    Navigator.pop(context);
  }

  void _onTextChanged(String value) {
    _recipeName = value;
  }
}
