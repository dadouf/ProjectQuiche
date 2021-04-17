import 'package:flutter/material.dart';

class IconAvatar extends StatelessWidget {
  const IconAvatar({
    Key? key,
    required this.icon,
    this.backgroundColor,
    this.color,
    this.radius,
  }) : super(key: key);

  final IconData icon;
  final Color? backgroundColor;
  final Color? color;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final rad = radius ?? defaultAvatarRadius;

    return CircleAvatar(
      radius: rad,
      backgroundColor: backgroundColor ?? Colors.white,
      child: Icon(
        icon,
        color: color ?? Theme.of(context).colorScheme.background,
        size: rad * 1.2,
      ),
    );
  }
}

const double defaultAvatarRadius = 25;
