import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/models/app_user.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';

class GroupsScreen extends StatelessWidget {
  final Query _query = MyFirestore.groups();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _query.snapshots(),
      builder: (context, snapshot) {
        try {
          return ListView(
              children: snapshot.data!.docs.map((e) {
            final user = AppUser.fromDocument(e);
            return ListTile(
              title: Text(user.username),
            );
          }).toList());
        } catch (e) {
          return Center(child: Text("Nothing to show yet"));
        }
      },
    );
  }
}
