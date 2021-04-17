import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/utils/app_icons.dart';
import 'package:projectquiche/widgets/avatar.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final appUser = context.read<AppModel>().currentUser;

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
  @override
  Widget build(BuildContext context) {
    // Check https://api.flutter.dev/flutter/widgets/ClipPath-class.html
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 200,
          child: Container(
            color: Color(0xFFB71540),
          ),
        ),
        IconAvatar(
          icon: AppIcons.chef_hat, // FIXME
          color: Color(0xFFB71540),
        ),
      ],
    );
  }
}
