import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/data/recipe.dart';
import 'package:projectquiche/services/error_reporting_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:projectquiche/utils/safe_print.dart';
import 'package:projectquiche/widgets/single_child_draggable_scroll_view.dart';
import 'package:provider/provider.dart';

class MyRecipesScreen extends StatefulWidget {
  MyRecipesScreen({required this.onRecipeTap, Key? key}) : super(key: key);

  final Function(Recipe recipe) onRecipeTap;

  final Query<Map<String, dynamic>> _query = MyFirestore.myRecipes()
      .where(MyFirestore.fieldStatus, isEqualTo: "active")
      .where(MyFirestore.fieldUserId,
          isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .orderBy(MyFirestore.fieldName);

  @override
  _MyRecipesScreenState createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _stream;
  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>? _latestSnapshot;

  @override
  void initState() {
    super.initState();
    _stream = widget._query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: () => _refreshData(showSnackBar: true),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _stream,
          // TODO this throws an error in the console when logging out because permission
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            // No need to wrap in setState because this doesn't impact the UI.
            // It's used for business logic on refresh.
            _latestSnapshot = snapshot;

            if (snapshot.hasError) {
              context
                  .read<ErrorReportingService>()
                  .recordError(snapshot.error, snapshot.stackTrace);
              return SingleChildDraggableScrollView(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    AppLocalizations.of(context)!
                        .screenLoadError(snapshot.error ?? "Unknown"),
                    textAlign: TextAlign.center,
                  ),
                ),
                parentConstraints: constraints,
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final List<Recipe> recipes = [];

            docs.forEach((doc) {
              // Protect against future data model changes
              try {
                recipes.add(Recipe.fromDocument(doc));
              } catch (e, stackTrace) {
                context
                    .read<ErrorReportingService>()
                    .recordError(e, stackTrace);
              }
            });

            if (recipes.isNotEmpty) {
              // TODO consider using ListView builder: maybe more efficient?
              return new ListView(
                children: recipes.map((Recipe recipe) {
                  return ListTile(
                    title: Text(recipe.name ?? "Untitled"),
                    onTap: () => widget.onRecipeTap(recipe),
                  );
                }).toList(),
              );
            } else {
              return SingleChildDraggableScrollView(
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.myRecipes_empty,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  parentConstraints: constraints);
            }
          },
        ),
      ),
    );
  }

  Future<void> _refreshData({bool showSnackBar = false}) async {
    if (_latestSnapshot?.hasData == true) {
      safePrint(
          "Skip refresh: we already have data and are listening to changes");
    } else {
      setState(() => _stream = widget._query.snapshots());
    }
  }
}
