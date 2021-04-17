import 'package:flutter/material.dart';

class IconAvatar extends StatelessWidget {
  const IconAvatar({
    Key? key,
    required this.icon,
    this.backgroundColor,
    this.color,
  }) : super(key: key);

  final IconData icon;
  final Color? backgroundColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: defaultAvatarRadius,
      backgroundColor: backgroundColor ?? Colors.white,
      child: Icon(
        icon,
        color: color ?? Theme.of(context).colorScheme.background,
        size: 30,
      ),
    );
  }
}

const double defaultAvatarRadius = 25;
