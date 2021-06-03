import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/data/group.dart';
import 'package:projectquiche/data/recipe.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/models/user_data_model.dart';
import 'package:projectquiche/services/error_reporting_service.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:projectquiche/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class CreateRecipeScreen extends StatelessWidget {
  const CreateRecipeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RecipeInputScreen(
      title: AppLocalizations.of(context)!.addRecipe,
      onRecipeCompleted: (Recipe writtenRecipe) async {
        final appModel = context.read<AppModel>();

        try {
          final user = appModel.currentUser!;

          await MyFirestore.myRecipes().add({
            MyFirestore.fieldUserId: user.userId,
            MyFirestore.fieldCreator: user.toJson(),
            MyFirestore.fieldCreationDate: DateTime.now(),
            MyFirestore.fieldStatus: "active",
            MyFirestore.fieldIsPublic: writtenRecipe.isPublic,
            MyFirestore.fieldSharedWithGroups: writtenRecipe.sharedWithGroups,
            MyFirestore.fieldName: writtenRecipe.name,
            MyFirestore.fieldIngredients: writtenRecipe.ingredients,
            MyFirestore.fieldSteps: writtenRecipe.steps,
            MyFirestore.fieldTips: writtenRecipe.tips,
          });

          appModel.completeWritingRecipe();

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.addRecipe_success),
          ));
        } catch (e, trace) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.addRecipe_failure(e)),
          ));
          context.read<ErrorReportingService>().recordError(e, trace);
        }
      },
    );
  }
}

class EditRecipeScreen extends StatelessWidget {
  final Recipe recipe;

  const EditRecipeScreen(this.recipe, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RecipeInputScreen(
      title: AppLocalizations.of(context)!.editRecipe,
      initialRecipe: recipe,
      onRecipeCompleted: (Recipe writtenRecipe) async {
        try {
          await MyFirestore.myRecipes().doc(recipe.id).update({
            MyFirestore.fieldName: writtenRecipe.name,
            MyFirestore.fieldIngredients: writtenRecipe.ingredients,
            MyFirestore.fieldSteps: writtenRecipe.steps,
            MyFirestore.fieldTips: writtenRecipe.tips,
            MyFirestore.fieldIsPublic: writtenRecipe.isPublic,
            MyFirestore.fieldSharedWithGroups: writtenRecipe.sharedWithGroups,
          });

          context.read<AppModel>().completeWritingRecipe();

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.editRecipe_success),
          ));
          // FIXME the context is wrong here, I should show

        } catch (e, trace) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.editRecipe_failure(e)),
          ));
          context.read<ErrorReportingService>().recordError(e, trace);
        }
      },
    );
  }
}

class RecipeInputScreen extends StatefulWidget {
  final String title;
  final Recipe? initialRecipe;
  final void Function(Recipe recipe) onRecipeCompleted;

  const RecipeInputScreen(
      {required this.title,
      this.initialRecipe,
      required this.onRecipeCompleted,
      Key? key})
      : super(key: key);

  @override
  _RecipeInputScreenState createState() => _RecipeInputScreenState();
}

class _RecipeInputScreenState extends State<RecipeInputScreen>
    with SingleTickerProviderStateMixin {
  // Note: right now 1 tab = 1 field, but this will change

  late List<Tab> _tabs = [];

  late TextEditingController _recipeName;
  late TextEditingController _recipeIngredients;
  late TextEditingController _recipeSteps;
  late TextEditingController _recipeTips;

  late TabController _tabController;
  late List<FocusNode> _focusNodes;

  final _nameKey = GlobalKey<FormFieldState>();

  late PerceivedRecipeVisibility _recipeVisibility;
  List<Group?>? _sharedWithGroups;

  @override
  void initState() {
    super.initState();

    _recipeName = TextEditingController(text: widget.initialRecipe?.name);
    _recipeIngredients =
        TextEditingController(text: widget.initialRecipe?.ingredients);
    _recipeSteps = TextEditingController(text: widget.initialRecipe?.steps);
    _recipeTips = TextEditingController(text: widget.initialRecipe?.tips);

    if (widget.initialRecipe?.isPublic == true) {
      _recipeVisibility = PerceivedRecipeVisibility.public;
    } else if (widget.initialRecipe?.sharedWithGroups.isNotEmpty == true) {
      _recipeVisibility = PerceivedRecipeVisibility.groups;
    } else {
      _recipeVisibility = PerceivedRecipeVisibility.private;
    }

    _focusNodes = [FocusNode(), FocusNode(), FocusNode(), FocusNode()];

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabControllerEvent);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabControllerEvent);
    _tabController.dispose();

    _focusNodes.forEach((element) {
      element.dispose();
    });

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _tabs = [
      Tab(text: AppLocalizations.of(context)!.info),
      Tab(text: AppLocalizations.of(context)!.ingredients),
      Tab(text: AppLocalizations.of(context)!.steps),
      Tab(text: AppLocalizations.of(context)!.tips),
    ];

    if (_sharedWithGroups == null) {
      final List<Group> groups = [];

      final userGroups = context.read<UserDataModel>().groups;
      widget.initialRecipe?.sharedWithGroups.forEach((groupId) {
        try {
          final group =
              userGroups.firstWhere((userGroup) => userGroup.id == groupId);
          groups.add(group);
        } catch (e) {}
      });

      _sharedWithGroups = groups;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _onSavePressed)
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          isScrollable: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            ListView(
              children: [
                TextFormField(
                  key: _nameKey,
                  focusNode: _focusNodes[0],
                  controller: _recipeName,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.recipe_name),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (_validateName()) {
                      return null;
                    } else {
                      return AppLocalizations.of(context)!.required;
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<PerceivedRecipeVisibility>(
                  value: _recipeVisibility,
                  decoration: InputDecoration(
                      labelText: "Visibility", border: InputBorder.none),
                  items: [
                    DropdownMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 16),
                          Text("Only me"),
                        ],
                      ),
                      value: PerceivedRecipeVisibility.private,
                    ),
                    DropdownMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.people),
                          SizedBox(width: 16),
                          Text("Only these groups..."),
                        ],
                      ),
                      value: PerceivedRecipeVisibility.groups,
                    ),
                    DropdownMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.public),
                          SizedBox(width: 16),
                          Text("Public"),
                        ],
                      ),
                      value: PerceivedRecipeVisibility.public,
                    ),
                  ],
                  onChanged: (value) {
                    if (value == PerceivedRecipeVisibility.groups &&
                        _recipeVisibility != PerceivedRecipeVisibility.groups) {
                      // In case selection is cancelled, fallback to the previous option
                      _selectGroupsForSharing(fallback: _recipeVisibility);
                    }

                    if (value != null) {
                      setState(() {
                        _recipeVisibility = value;

                        if (_recipeVisibility !=
                            PerceivedRecipeVisibility.groups) {
                          _sharedWithGroups?.clear();
                        }
                      });
                    }
                  },
                ),
                if (_sharedWithGroups?.isNotEmpty == true)
                  Row(
                    children: [
                      SizedBox(width: 24 + 16),
                      Expanded(
                          child: Text(_sharedWithGroups
                                  ?.map((e) => e?.name ?? "Unknown")
                                  .join(", ") ??
                              "Unknown")),
                      TextButton(
                        onPressed: () => _selectGroupsForSharing(
                            fallback: _recipeVisibility),
                        child: Text("SELECT"),
                      ),
                      SizedBox(width: 24),
                    ],
                  )
              ],
            ),
            TextFormField(
              focusNode: _focusNodes[1],
              controller: _recipeIngredients,
              decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.ingredients_hint),
              textCapitalization: TextCapitalization.sentences,
              expands: true,
              maxLines: null,
              minLines: null,
            ),
            TextFormField(
              focusNode: _focusNodes[2],
              controller: _recipeSteps,
              decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.steps_hint),
              textCapitalization: TextCapitalization.sentences,
              expands: true,
              maxLines: null,
              minLines: null,
            ),
            TextFormField(
              focusNode: _focusNodes[3],
              controller: _recipeTips,
              decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.tips_hint),
              textCapitalization: TextCapitalization.sentences,
              expands: true,
              maxLines: null,
              minLines: null,
            ),
          ],
        ),
      ),
    );
  }

  void _selectGroupsForSharing(
      {required PerceivedRecipeVisibility fallback}) async {
    final groups = context.read<UserDataModel>().groups;
    groups.sort((g1, g2) => g1.name.compareTo(g2.name));

    final List<Group?>? result = await showDialog<List<Group?>>(
        context: context,
        builder: (BuildContext context) => MultiSelectDialog<Group?>(
            title: "Select groups",
            items: groups,
            itemDescriptor: (Group? g) => g?.name ?? "Unknown",
            selectedItems: _sharedWithGroups ?? []));

    print(result);

    if (result == null) {
      setState(() => _recipeVisibility = fallback);
    } else if (result.isEmpty) {
      setState(() {
        _recipeVisibility = PerceivedRecipeVisibility.private;
        _sharedWithGroups = [];
      });
    } else {
      setState(() {
        _recipeVisibility = PerceivedRecipeVisibility.groups;
        _sharedWithGroups = result;
      });
    }
  }

  void _onSavePressed() {
    if (_validateForm()) {
      context.read<FirebaseService>().logSave();

      final prospectiveRecipe = Recipe(
        name: _recipeName.text,
        ingredients: _recipeIngredients.text,
        steps: _recipeSteps.text,
        tips: _recipeTips.text,
        isPublic: _recipeVisibility == PerceivedRecipeVisibility.public,
        sharedWithGroups: _sharedWithGroups?.map((e) => e!.id).toList() ?? [],
      );

      widget.onRecipeCompleted(prospectiveRecipe);
    } else {
      // Animate to the tab that needs to change
      _tabController.animateTo(0);

      // Also display validation errors now in case we're already in the correct tab
      _displayValidationErrors();
    }
  }

  /// Note: validation of the full Form at once doesn't work because TabBarView
  /// doesn't really have all 4 children existing at once. Only the current one
  /// is attached, therefore validate() would only validate the currently
  /// displayed field.
  /// Instead, we manually validate the fields based on their state value.

  bool _validateForm() => _validateName();

  bool _validateName() => _recipeName.text.isNotEmpty;

  void _onTabControllerEvent() {
    // Upon settling...
    if (!_tabController.indexIsChanging) {
      if (_tabController.index == 0) {
        // ... show validation errors
        _displayValidationErrors();
      } else {
        // ... focus text field
        // FIXME small issue (maybe in Flutter): this always capitalizes even if there is a current text (Android-only apparently)
        _focusNodes[_tabController.index].requestFocus();
      }
    }
  }

  void _displayValidationErrors() {
    _nameKey.currentState?.validate();
  }
}
