import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/data/group.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/models/user_data_model.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatefulWidget {
  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    final groups = context.select((UserDataModel model) => model.groups);

    if (groups.isNotEmpty) {
      return ListView(
          children: groups.map((group) {
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
  }

  _openGroup(BuildContext context, Group group) {
    context.read<AppModel>().startViewingGroup(group);
  }
}
