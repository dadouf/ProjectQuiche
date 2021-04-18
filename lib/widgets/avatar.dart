import 'package:flutter/material.dart';
import 'package:projectquiche/models/app_user.dart';

class AvatarWidget extends StatelessWidget {
  final AppUser user;
  final double? radius;

  const AvatarWidget({
    Key? key,
    required this.user,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = user.avatarType?.icon;
    final rad = radius ?? defaultAvatarRadius;

    if (icon != null) {
      return IconAvatar(
        icon: icon,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        radius: rad,
      );
    } else if (user.avatarUrl != null) {
      return CircleAvatar(
        radius: rad,
        foregroundImage: NetworkImage(user.avatarUrl!),
      );
    } else {
      return Container();
    }
  }
}

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
