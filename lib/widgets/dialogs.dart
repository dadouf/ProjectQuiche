import 'package:flutter/material.dart';

///
class MultiSelectDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T item) itemDescriptor;

  const MultiSelectDialog({
    Key? key,
    required this.title,
    required this.items,
    required this.itemDescriptor,
    this.selectedItems = const [],
  }) : super(key: key);

  @override
  _MultiSelectDialogState<T> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState<T> extends State<MultiSelectDialog<T>> {
  late List<bool> selectionStates;

  @override
  void initState() {
    super.initState();

    selectionStates = List.filled(widget.items.length, false);

    widget.selectedItems.forEach((element) {
      final index = widget.items.indexOf(element);
      selectionStates[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.only(top: 16),
      title: Text(widget.title),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: widget.items
                .asMap()
                .entries
                .map((MapEntry<int, T> indexedItem) {
              final index = indexedItem.key;
              final item = indexedItem.value;

              return CheckboxListTile(
                  contentPadding: EdgeInsets.only(left: 24, right: 16),
                  value: selectionStates[index],
                  title: Text(widget.itemDescriptor(item)),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectionStates[index] = value);
                    }
                  });
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("CANCEL"),
        ),
        TextButton(
          onPressed: () {
            final List<T> selectedItems = widget.items
                .asMap()
                .entries
                .where((indexedItem) => selectionStates[indexedItem.key])
                .map((indexedItem) => indexedItem.value)
                .toList();
            Navigator.pop(context, selectedItems);
          },
          child: Text("CONFIRM"),
        ),
      ],
    );
  }
}
