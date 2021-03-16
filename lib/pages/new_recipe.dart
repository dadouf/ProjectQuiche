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
    MyFirestore.recipes().add({
      MyFirestore.fieldName: _recipeName,
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

  void _onTextChanged(String value) {
    _recipeName = value;
  }
}
