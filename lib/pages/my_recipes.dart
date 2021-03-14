import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/model/recipe.dart';
import 'package:projectquiche/pages/recipe.dart';

class MyRecipesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Query recipes = FirebaseFirestore.instance
        .collection("recipes")
        .orderBy("name")
        .where("created_by", isEqualTo: FirebaseAuth.instance.currentUser?.uid);

    return StreamBuilder<QuerySnapshot>(
      stream: recipes.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
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
