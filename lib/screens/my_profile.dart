import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/models/app_user.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/widgets/avatar.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return ListView(
      children: [
        // HeroHeader(),
        if (firebaseUser?.email != null)
          ListTile(
            leading: Icon(Icons.email),
            title: Text(firebaseUser!.email!),
          ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text(AppLocalizations.of(context)!.signOut),
          onTap: () => _logout(context),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.info_outline),
          title: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                String? appName = snapshot.data?.appName;
                String? packageName = snapshot.data?.packageName;
                String? version = snapshot.data?.version;
                String? buildNumber = snapshot.data?.buildNumber;

                return Text("$appName v$version+$buildNumber\n$packageName");
              }),
        ),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await context.read<FirebaseService>().signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to sign out: $e"),
      ));
    }
  }
}

class HeroHeader extends StatelessWidget {
  final avatarRadius = defaultAvatarRadius * 1.5;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppModel appModel) => appModel.currentUser);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 170,
          child: Padding(
            padding: EdgeInsets.only(bottom: avatarRadius),
            child: ClipPath(
              clipper: CurvedBottomClipper(),
              child: Container(
                color: Color(0xFFB71540),
              ),
            ),
          ),
        ),
        if (user != null)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.username,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(height: 16),
              _buildAvatar(user),
            ],
          ),
      ],
    );
  }

  Widget _buildAvatar(AppUser user) {
    final icon = user.avatarType?.icon;

    if (icon != null) {
      return IconAvatar(
        icon: icon,
        color: Color(0xFFB71540),
        radius: avatarRadius,
      );
    } else if (user.avatarUrl != null) {
      return CircleAvatar(
        radius: avatarRadius,
        foregroundImage: NetworkImage(user.avatarUrl!),
      );
    } else {
      return Container();
    }
  }
}

/// Inspired from https://stackoverflow.com/a/57199368/2291104
class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final roundingHeight = size.height * 2 / 5;
    final double lateralOverflow = size.width / 10;

    // Top part of path: a rectangle without any rounding
    final filledRectangle = Rect.fromLTRB(
      0,
      0,
      size.width,
      size.height - roundingHeight,
    );

    // Bottom part of the path: the rectangle that's used to draw the arc.
    // The arc is bound by the rectangle and drawn from its center,so its height
    // has to be twice the desired roundingHeight. It also overflows on the
    // left and right so that the edges are less abrupt.
    final roundingRectangle = Rect.fromLTRB(
      -lateralOverflow,
      size.height - roundingHeight * 2,
      size.width + lateralOverflow,
      size.height,
    );

    final path = Path();
    path.addRect(filledRectangle);

    // Draw the arc in a 180 degrees angle. The 4th argument is true to move
    // the path to rectangle center, so we don't have to move it manually.
    path.arcTo(roundingRectangle, pi, -pi, true);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
