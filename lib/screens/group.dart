import 'package:flutter/material.dart';
import 'package:projectquiche/data/group.dart';
import 'package:projectquiche/data/recipe.dart';
import 'package:projectquiche/models/user_data_model.dart';
import 'package:projectquiche/widgets/avatar.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatefulWidget {
  final Group _group;

  GroupScreen(this._group);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Recipe> groupRecipes = context.select((UserDataModel model) =>
        model.recipes
            .where(
                (recipe) => recipe.sharedWithGroups.contains(widget._group.id))
            .toList());
    final asMember = groupRecipes.length > 0;

    return DefaultTabController(
      length: asMember ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget._group.name),
          actions: [
            IconButton(
                icon: Icon(Icons.group_add),
                onPressed: () => _onInviteButtonClicked(context))
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: "Info"),
              Tab(text: "Members"),
              if (asMember) Tab(text: "Recipes"),
            ],
            isScrollable: true,
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: [
                ListTile(
                    title: Text("Created on ${widget._group.creationDate}")),
                ListTile(
                    title: Text("${widget._group.members.length} members")),
                if (asMember)
                  ListTile(title: Text("${groupRecipes.length} recipes")),
              ],
            ),
            ListView.builder(
              itemCount: widget._group.members.length,
              itemBuilder: (BuildContext context, int index) {
                var member = widget._group.members[index];
                return ListTile(
                  leading: AvatarWidget(user: member, radius: 15),
                  title: Text(member.username),
                  subtitle: member.userId == widget._group.creator.userId
                      ? Text("Owner")
                      : null,
                );
              },
            ),
            if (asMember)
              ListView.builder(
                itemCount: groupRecipes.length,
                itemBuilder: (BuildContext context, int index) {
                  var recipe = groupRecipes[index];
                  return ListTile(
                    title: Text(recipe.name ?? "Untitled"),
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
