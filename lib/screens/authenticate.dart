import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projectquiche/models/app_user.dart';
import 'package:projectquiche/models/username_generator.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/utils/app_icons.dart';
import 'package:projectquiche/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthenticateScreen extends StatefulWidget {
  @override
  _AuthenticateScreenState createState() {
    return _AuthenticateScreenState();
  }
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  bool _isLoading = false;
  String _proposedUsername = generateUsername();
  AvatarType? _selectedAvatar;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const edgeInsets = EdgeInsets.all(16);

    final originalScheme = Theme.of(context).colorScheme;
    final boldColorScheme = originalScheme.copyWith(
      background: originalScheme.primary,
      onBackground: originalScheme.onPrimary,
      primary: originalScheme.background,
      onPrimary: originalScheme.onBackground,
      brightness: Brightness.dark,
    );

    final firebaseUser =
        context.select((FirebaseService firebase) => firebase.firebaseUser);
    final appUser =
        context.select((FirebaseService firebase) => firebase.appUser);

    return Theme(
      data: boldColorScheme.toTheme(),
      child: Builder(
        builder: (context) {
          var subtitleTextStyle = TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          );

          return Scaffold(
            body: Center(
              child: Padding(
                padding: edgeInsets,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Icon(Icons.restaurant, size: 92),
                    ),
                    Container(
                      child: Text(
                        "Project Quiche",
                        style: TextStyle(fontSize: 24),
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(bottom: 64),
                    ),
                    if (firebaseUser == null && !_isLoading) ...[
                      // Sign in buttons
                      Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ElevatedButton(
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 44, // to match Apple
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .signInWithGoogle,
                                      style: TextStyle(
                                          fontSize:
                                              44 * 0.43), // to match Apple
                                    ),
                                  ),
                                  onPressed: _signInWithGoogle,
                                ),
                              ),
                              if (!kIsWeb && Platform.isIOS)
                                SignInWithAppleButton(
                                  onPressed: _signInWithApple,
                                  text: AppLocalizations.of(context)!
                                      .signInWithApple,
                                )
                            ]),
                      )
                    ] else if (firebaseUser != null && appUser == null) ...[
                      Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Your account has been created.\nPlease complete your profile.",
                                textAlign: TextAlign.center,
                              ),
                              Spacer(),
                              Text("Pick an avatar", style: subtitleTextStyle),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (firebaseUser.photoURL != null)
                                    SelectableBox(
                                      child: CircleAvatar(
                                        radius: circleAvatarRadius,
                                        // FIXME this displays black while it loads
                                        foregroundImage: NetworkImage(
                                            firebaseUser.photoURL!),
                                      ),
                                      isSelected:
                                          _selectedAvatar == AvatarType.social,
                                      onTap: () => setState(() =>
                                          _selectedAvatar = AvatarType.social),
                                    ),
                                  SelectableBox.iconAvatar(
                                    icon: AppIcons.chef_hat,
                                    isSelected:
                                        _selectedAvatar == AvatarType.chef_hat,
                                    onTap: () => setState(() =>
                                        _selectedAvatar = AvatarType.chef_hat),
                                  ),
                                  SelectableBox.iconAvatar(
                                    icon: AppIcons.salt_and_pepper,
                                    isSelected: _selectedAvatar ==
                                        AvatarType.salt_and_pepper,
                                    onTap: () => setState(() =>
                                        _selectedAvatar =
                                            AvatarType.salt_and_pepper),
                                  ),
                                  SelectableBox.iconAvatar(
                                    icon: AppIcons.food_tray,
                                    isSelected:
                                        _selectedAvatar == AvatarType.food_tray,
                                    onTap: () => setState(() =>
                                        _selectedAvatar = AvatarType.food_tray),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Text("Pick a username", style: subtitleTextStyle),
                              SizedBox(height: 16),
                              SelectableBox(
                                padding: EdgeInsets.only(left: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _proposedUsername,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    IconButton(
                                        splashRadius: 24,
                                        icon: Icon(Icons.refresh),
                                        onPressed: _proposeNewUsername)
                                  ],
                                ),
                                isSelected: true,
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: _cancelProfile,
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: _selectedAvatar != null
                                        ? _completeProfile
                                        : null,
                                    child: Text("Create profile"),
                                  ),
                                ],
                              ),
                              Spacer(),
                            ]),
                      )
                    ] else ...[
                      Expanded(
                          child: Center(child: CircularProgressIndicator()))
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<UserCredential?> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _signIn(credential: credential, method: "Google");

      // FIXME DO NOT setState here: keep loading the loading spinner until
      //  the _firebaseUser and _appUser change
    } on Exception catch (e, stackTrace) {
      _handleError(e, stackTrace);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        accessToken: appleCredential.authorizationCode,
        idToken: appleCredential.identityToken,
      );

      await _signIn(credential: credential, method: "Apple");

      // FIXME DO NOT setState here: keep loading the loading spinner until
      //  the _firebaseUser and _appUser change
    } on Exception catch (e, stackTrace) {
      _handleError(e, stackTrace);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signIn({
    required OAuthCredential credential,
    required String method,
  }) async {
    await context
        .read<FirebaseService>()
        .signIn(credential: credential, method: method);
  }

  void _handleError(exception, trace) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Failed to sign in: $exception"),
    ));
    context.read<FirebaseService>().recordError(exception, trace);
  }

  void _proposeNewUsername() {
    setState(() => _proposedUsername = generateUsername());
    // TODO check that the proposed username is unique (cloud function)
  }

  void _cancelProfile() async {
    // copied from my_profile.dart TODO factor

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

  Future<void> _completeProfile() async {
    setState(() => _isLoading = true);
    await context
        .read<FirebaseService>()
        .completeProfile(_proposedUsername, _selectedAvatar!);
    setState(() => _isLoading = false);
  }
}

class SelectableBox extends StatelessWidget {
  const SelectableBox({
    Key? key,
    required this.child,
    this.isSelected = false,
    this.onTap,
    this.padding = const EdgeInsets.all(12),
  }) : super(key: key);

  SelectableBox.iconAvatar({
    Key? key,
    required IconData icon,
    required this.isSelected,
    required this.onTap,
    this.padding = const EdgeInsets.all(12),
  })  : child = _IconAvatar(icon: icon),
        super(key: key);

  final Widget child;
  final bool isSelected;
  final GestureTapCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    // Keep InkWell and Container synced. I guess there's a way to have it
    // automatically.
    final borderRadius = BorderRadius.circular(0);

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
          decoration: ShapeDecoration(
              color: Color(isSelected ? 0x40FFFFFF : 0),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Color(isSelected ? 0x50FFFFFF : 0),
                    width: 2.0,
                  ),
                  borderRadius: borderRadius)),
          padding: padding,
          child: child),
    );
  }
}

class _IconAvatar extends StatelessWidget {
  const _IconAvatar({Key? key, required this.icon}) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.background;

    return CircleAvatar(
      radius: circleAvatarRadius,
      backgroundColor: Colors.white,
      child: Icon(
        icon,
        color: iconColor,
        size: 30,
      ),
    );
  }
}

const double circleAvatarRadius = 25;
