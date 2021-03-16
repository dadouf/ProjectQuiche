import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/data/MyFirestore.dart';

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
    MyFirestore.recipes()
        .add({
          MyFirestore.FIELD_NAME: _recipeName,
          MyFirestore.FIELD_CREATED_BY: {
            MyFirestore.FIELD_UID: FirebaseAuth.instance.currentUser?.uid,
            MyFirestore.FIELD_NAME:
                FirebaseAuth.instance.currentUser?.displayName
          },
          MyFirestore.FIELD_MOVED_TO_BIN: false
        })
        .then((value) => print("Recipe Added"))
        .catchError((error) => print("Failed to add recipe: $error"));

    Navigator.pop(context);
  }

  void _onTextChanged(String value) {
    _recipeName = value;
  }
}
