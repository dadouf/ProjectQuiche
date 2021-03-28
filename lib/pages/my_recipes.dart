import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/data/MyFirestore.dart';
import 'package:projectquiche/model/recipe.dart';
import 'package:projectquiche/widgets/single_child_draggable_scroll_view.dart';

class MyRecipesPage extends StatefulWidget {
  MyRecipesPage({required this.onRecipeTap, Key? key}) : super(key: key);

  final Function(Recipe recipe) onRecipeTap;

  final Query _query = MyFirestore.recipes()
      // Note: "isNotEqualTo: true" isn't allowed
      .where(MyFirestore.fieldMovedToBin, isEqualTo: false)
      .where("${MyFirestore.fieldCreatedBy}.${MyFirestore.fieldUid}",
          isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .orderBy(MyFirestore.fieldName);

  @override
  _MyRecipesPageState createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  late Stream<QuerySnapshot> _stream;
  AsyncSnapshot<QuerySnapshot>? _latestSnapshot;

  @override
  void initState() {
    super.initState();

    _stream = widget._query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: () => _refreshData(showSnackBar: true),
        child: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            // No need to wrap in setState because this doesn't impact the UI.
            // It's used for business logic on refresh.
            _latestSnapshot = snapshot;

            if (snapshot.hasError) {
              FirebaseCrashlytics.instance
                  .recordError(snapshot.error, snapshot.stackTrace);
              return SingleChildDraggableScrollView(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Couldn't load screen. Please try again later.\n\nError: ${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                ),
                parentConstraints: constraints,
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            var docs = snapshot.data!.docs;
            if (docs.isNotEmpty) {
              return new ListView(
                children: docs.map((DocumentSnapshot document) {
                  var recipe = Recipe.fromDocument(document);
                  return ListTile(
                    title: Text(recipe.name ?? "Untitled"),
                    onTap: () {
                      widget.onRecipeTap(recipe);
                    },
                  );
                }).toList(),
              );
            } else {
              return SingleChildDraggableScrollView(
                  child: Center(
                      child: Text(
                          "You don't have any recipes. Start adding some now!")),
                  parentConstraints: constraints);
            }
          },
        ),
      ),
    );
  }

  _refreshData({bool showSnackBar = false}) async {
    if (_latestSnapshot?.hasData == true) {
      print("Skip refresh: we already have data and are listening to changes");
    } else {
      setState(() {
        _stream = widget._query.snapshots();
      });
    }
  }
}
