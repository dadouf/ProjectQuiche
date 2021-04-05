import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.person),
          title: Text(AppLocalizations.of(context)!.connectedAs(
              FirebaseAuth.instance.currentUser?.email ?? "Unknown")),
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
    final service = context.read<FirebaseService>();
    try {
      // This is enough to go back to Login screen
      await service.signOut();

      // This is needed in order to PROMPT user again
      await GoogleSignIn().signOut();

      // ... will cause AppModel update because FirebaseService.isSignedIn will change
    } on Exception catch (exception, stack) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to sign out: $exception"),
      ));
      service.recordError(exception, stack);
    }
  }
}
