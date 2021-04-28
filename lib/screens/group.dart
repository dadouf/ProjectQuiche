import 'package:flutter/material.dart';
import 'package:projectquiche/models/group.dart';
import 'package:projectquiche/widgets/avatar.dart';

class GroupScreen extends StatelessWidget {
  final Group _group;

  GroupScreen(this._group);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_group.name ?? "Untitled"),
          actions: [
            IconButton(
                icon: Icon(Icons.group_add),
                onPressed: () => _onInviteButtonClicked(context))
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: "Info"),
              Tab(text: "Recipes"),
              Tab(text: "Members"),
            ],
            isScrollable: true,
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: [
                ListTile(title: Text("Created on ${_group.creationDate}")),
                ListTile(title: Text("0 recipes")),
                ListTile(title: Text("${_group.members.length} members")),
              ],
            ),
            ListView(),
            ListView.builder(
              itemCount: _group.members.length,
              itemBuilder: (BuildContext context, int index) {
                var member = _group.members[index];
                return ListTile(
                  leading: AvatarWidget(user: member, radius: 15),
                  title: Text(member.username),
                  subtitle: member.userId == _group.creator.userId
                      ? Text("Owner")
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  _onInviteButtonClicked(BuildContext context) {}
}
