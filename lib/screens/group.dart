import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/data/app_user.dart';
import 'package:projectquiche/data/group.dart';
import 'package:projectquiche/data/recipe.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/models/user_data_model.dart';
import 'package:projectquiche/widgets/avatar.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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

    final AppUser? me = context.select((AppModel model) => model.user);

    final asMember = me != null &&
        widget._group.members.any((member) => member.userId == me.userId);

    return DefaultTabController(
      length: asMember ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget._group.name),
          actions: [
            if (asMember)
              IconButton(
                  icon: Icon(Icons.group_add),
                  onPressed: _onInviteButtonClicked)
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
                    // TODO factor common logic for username vs "me" (in recipe and in group)
                    title: Text(AppLocalizations.of(context)!
                        .group_created_by_on(widget._group.creator.username,
                            widget._group.creationDate!))),
                ListTile(
                    title: Text("${widget._group.members.length} members")),
                if (asMember)
                  ListTile(title: Text("${groupRecipes.length} recipes")),
                Center(
                  child: ElevatedButton(
                    onPressed: asMember ? _leaveGroup : _joinGroup,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        asMember ? "Leave group" : "Join group",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(64.0),
                    ))),
                  ),
                )
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

  Future<void> _onInviteButtonClicked() async {
    final link = await _buildDynamicLink();
    Share.share('Join my group on Project Quiche: $link');
  }

  Future<String> _buildDynamicLink() async {
    // TODO review the format of this
    //  - if I don't use custom domain, then the link URL should be a valid link to a webpage
    //  - if I use custom domain, then the URI prefix + link should be a valid link to a webpage
    // The link part is what gets parsed by AppRouteParser, keep them in sync.
    final parameters = DynamicLinkParameters(
      uriPrefix: "https://projectquichedev.page.link",
      link: Uri.parse("https://davidferrand.com/groups/${widget._group.id}"),
      // TODO not sure whether these are necessary, but they sure seemed to help on Android 4.4
      androidParameters: AndroidParameters(
        packageName: 'com.davidferrand.projectquiche.debug',
      ),
      iosParameters: IosParameters(
        bundleId: 'com.davidferrand.projectquiche.debug',
        appStoreId: '962194608',
      ),
    );

    final Uri dynamicUrl = await parameters.buildUrl();

    return dynamicUrl.toString();
  }

  _leaveGroup() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("TODO leave group")));
  }

  _joinGroup() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("TODO join group")));
  }
}
