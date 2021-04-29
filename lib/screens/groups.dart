import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/data/group.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatefulWidget {
  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  // TODO use UserDataModel instead of this
  final Query _query = MyFirestore.groups()
      .where("members", arrayContains: FirebaseAuth.instance.currentUser?.uid);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            context
                .read<FirebaseService>()
                .recordError(snapshot.error, snapshot.stackTrace);
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16),
              child: Text(
                AppLocalizations.of(context)!
                    .screenLoadError(snapshot.error ?? "Unknown"),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;
          if (docs.isNotEmpty) {
            return ListView(
                children: snapshot.data!.docs.map((e) {
              final group = Group.fromDocument(e);
              return ListTile(
                title: Text(group.name),
                onTap: () => _openGroup(context, group),
              );
            }).toList());
          } else {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.groups_empty,
                textAlign: TextAlign.center,
              ),
            );
          }
        });
  }

  _openGroup(BuildContext context, Group group) {
    context.read<AppModel>().startViewingGroup(group);
  }
}
