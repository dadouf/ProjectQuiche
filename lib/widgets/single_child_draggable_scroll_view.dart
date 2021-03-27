import 'package:flutter/material.dart';

/// ListView with a single child that is draggable in order to pull-to-refresh
/// Based on: https://stackoverflow.com/a/62157637/2291104
class SingleChildDraggableScrollView extends StatelessWidget {
  const SingleChildDraggableScrollView({
    Key? key,
    required this.child,
    required this.parentConstraints,
  }) : super(key: key);

  final Widget child;
  final BoxConstraints parentConstraints;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: parentConstraints.maxHeight),
          child: child),
    );
  }
}
