import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NewRecipePage extends StatefulWidget {
  const NewRecipePage({Key key}) : super(key: key);

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
            RaisedButton(
              child: Text('Add'),
              onPressed: _postNewRecipe,
            )
          ],
        ));
  }

  void _postNewRecipe() {
    FirebaseDatabase.instance.reference().child("v1/recipes").push().set({
      "name": _recipeName,
      "created_by": FirebaseAuth.instance.currentUser.uid,
    });

    Navigator.pop(context);
  }

  void _onTextChanged(String value) {
    _recipeName = value;
  }
}
