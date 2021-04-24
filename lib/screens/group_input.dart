import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/models/group.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GroupInputScreen(
      title: AppLocalizations.of(context)!.createGroup,
      onSave: ({required name, required acceptsNewMembers}) async {
        final appModel = context.read<AppModel>();

        try {
          final user = appModel.currentUser!;

          await MyFirestore.groups().add({
            MyFirestore.fieldCreator: user.toJson(),
            MyFirestore.fieldCreationDate: DateTime.now(),
            MyFirestore.fieldStatus: "active",
            MyFirestore.fieldName: name,
            MyFirestore.fieldAcceptsNewMembers: acceptsNewMembers,
            MyFirestore.fieldMembers: [user.uid],
          });

          appModel.completeWritingGroup();

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.createGroup_success),
          ));
        } catch (e, trace) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.createGroup_failure(e)),
          ));
          context.read<FirebaseService>().recordError(e, trace);
        }
      },
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
      onSave: ({required name, required acceptsNewMembers}) {},
    );
  }
}

class GroupInputScreen extends StatefulWidget {
  final String title;
  final Group? initialGroup;

  final void Function({
    required String name,
    required bool acceptsNewMembers,
  }) onSave;

  const GroupInputScreen(
      {required this.title, required this.onSave, this.initialGroup, Key? key})
      : super(key: key);

  @override
  _GroupInputScreenState createState() => _GroupInputScreenState();
}

class _GroupInputScreenState extends State<GroupInputScreen> {
  bool? _acceptsNewMembers = true;

  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.initialGroup?.name);
  }

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _onSavePressed)
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.group_name),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          CheckboxListTile(
            value: _acceptsNewMembers,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text("Accept new members"),
            onChanged: (value) {
              setState(() => _acceptsNewMembers = value);
            },
          )
        ],
      ),
    );
  }

  _onSavePressed() {
    widget.onSave(
        name: _nameController.text, acceptsNewMembers: _acceptsNewMembers!);
  }
}
