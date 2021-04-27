import 'package:flutter/material.dart';
import 'package:projectquiche/models/group.dart';

class GroupScreen extends StatelessWidget {
  final Group _group;

  GroupScreen(this._group);

  @override
  Widget build(BuildContext context) {
    var titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    var textStyle = TextStyle(fontSize: 16);
    var defaultPadding = const EdgeInsets.all(16.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(_group.name ?? "Untitled"),
        actions: [
          IconButton(
              icon: Icon(Icons.group_add),
              onPressed: () => _onInviteButtonClicked(context))
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: defaultPadding,
            child: Text(
              "Members",
              style: titleStyle,
            ),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(
              _group.members.toString(), // TODO show full User tile
              style: textStyle,
            ),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(
              "Recipes",
              style: titleStyle,
            ),
          ),
          Padding(
            padding: defaultPadding,
            child: Text(
              "TODO get recipes from repo", // TODO
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  _onInviteButtonClicked(BuildContext context) {}
}
