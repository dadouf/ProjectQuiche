import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/models/group.dart';

class CreateGroupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GroupInputScreen(
      title: AppLocalizations.of(context)!.createGroup,
      onSave: ({required name}) {},
    );
  }
}

class EditGroupScreen extends StatelessWidget {
  final Group group;

  EditGroupScreen(this.group);

  @override
  Widget build(BuildContext context) {
    return GroupInputScreen(
      title: AppLocalizations.of(context)!.editGroup,
      onSave: ({required name}) {},
    );
  }
}

class GroupInputScreen extends StatefulWidget {
  final String title;
  final Group? initialGroup;

  final void Function({
    required String name,
  }) onSave;

  const GroupInputScreen(
      {required this.title, required this.onSave, this.initialGroup, Key? key})
      : super(key: key);

  @override
  _GroupInputScreenState createState() => _GroupInputScreenState();
}

class _GroupInputScreenState extends State<GroupInputScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _onSavePressed)
        ],
      ),
    );
  }

  _onSavePressed() {}
}
