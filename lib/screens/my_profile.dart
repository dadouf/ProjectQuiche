import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/services/identity_service.dart';
import 'package:projectquiche/widgets/avatar.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return ListView(
      padding: EdgeInsets.only(top: 32),
      children: [
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
      await context.read<IdentityService>().signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to sign out: $e"),
      ));
    }
  }
}

class HeroHeader extends StatelessWidget {
  // TODO shadow https://stackoverflow.com/questions/55033726/can-i-draw-a-custom-box-shadow-in-flutter-using-canvas-in-a-custompaint
  final avatarRadius = defaultAvatarRadius * 1.5;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppModel appModel) => appModel.user);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: avatarRadius),
          child: ClipPath(
            clipper: CurvedBottomClipper(),
            child: Container(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        if (user != null)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 24),
              Text(
                user.username,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(height: 24),
              Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x30505050),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 2), // changes position of shadow
                      )
                    ],
                  ),
                  child: AvatarWidget(user: user, radius: avatarRadius)),
            ],
          ),
      ],
    );
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
