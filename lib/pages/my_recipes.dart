import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/data/MyFirestore.dart';
import 'package:projectquiche/model/recipe.dart';
import 'package:projectquiche/pages/recipe.dart';

class MyRecipesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Query recipes = MyFirestore.recipes()
        // Note: "isNotEqualTo: true" isn't allowed
        .where(MyFirestore.fieldMovedToBin, isEqualTo: false)
        .where("${MyFirestore.fieldCreatedBy}.${MyFirestore.fieldUid}",
            isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .orderBy(MyFirestore.fieldName);

    return StreamBuilder<QuerySnapshot>(
      stream: recipes.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          FirebaseCrashlytics.instance.recordError(
              snapshot.error, snapshot.stackTrace,
              reason: "Couldn't load My recipes");
          return Center(
              child: Text("Couldn't load screen. Please try again later."));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return new ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            var recipe = Recipe.fromDocument(document);
            return ListTile(
              title: Text(recipe.name ?? "No name"),
              onTap: () => _openRecipe(context, recipe),
            );
          }).toList(),
        );
      },
    );
  }

  void _openRecipe(BuildContext context, Recipe recipe) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RecipePage(recipe)));
  }
}
