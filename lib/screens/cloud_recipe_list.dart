import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';

class CloudRecipeListPage extends StatefulWidget {
  @override
  _CloudRecipeListPageState createState() => _CloudRecipeListPageState();
}

class _CloudRecipeListPageState extends State<CloudRecipeListPage>
    with StreamSubscriberMixin {
  final recipesDbRef = FirebaseDatabase.instance.reference().child("recipes");

  var text = "...";

  @override
  void initState() {
    super.initState();

    listen(recipesDbRef.onValue, (event) => updateState(event.snapshot));
  }

  void updateState(DataSnapshot snapshot) {
    setState(() {
      text = snapshot.value.toString();
    });
  }

  @override
  void dispose() {
    cancelSubscriptions();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Recipes')),
        body: ListView(
          children: [Text(text)],
        ));
  }
}
