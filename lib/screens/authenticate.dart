import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/models/app_user.dart';
import 'package:projectquiche/services/auth_service.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/ui/app_icons.dart';
import 'package:projectquiche/ui/app_theme.dart';
import 'package:projectquiche/widgets/avatar.dart';
import 'package:projectquiche/widgets/spinning.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthenticateScreen extends StatefulWidget {
  @override
  _AuthenticateScreenState createState() {
    return _AuthenticateScreenState();
  }
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  @override
  Widget build(BuildContext context) {
    const edgeInsets = EdgeInsets.all(16);

    final firebaseUser =
        context.select((FirebaseService firebase) => firebase.firebaseUser);
    final appUser =
        context.select((FirebaseService firebase) => firebase.appUser);

    return Theme(
      data: AppTheme.boldColorScheme.toTheme(),
      child: Builder(
        builder: (context) {
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
                    if (firebaseUser == null) ...[
                      // Sign in buttons
                      Expanded(child: SignInOptionsWidget())
                    ] else if (appUser == null) ...[
                      Expanded(child: CreateProfileWidget())
                    ] else ...[
                      // Note: in theory we should never get here because the app
                      // router should switch to another page, but just in case
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
  })  : child = IconAvatar(icon: icon),
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
              color: isSelected
                  ? AppColors.selectedBackgroundOnDark
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.selectedBorderOnDark
                        : Colors.transparent,
                    width: 2.0,
                  ),
                  borderRadius: borderRadius)),
          padding: padding,
          child: child),
    );
  }
}

class SignInOptionsWidget extends StatefulWidget {
  @override
  _SignInOptionsWidgetState createState() => _SignInOptionsWidgetState();
}

class _SignInOptionsWidgetState extends State<SignInOptionsWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ElevatedButton(
            child: Container(
              alignment: Alignment.center,
              height: 44, // to match Apple
              child: Text(
                AppLocalizations.of(context)!.signInWithGoogle,
                style: TextStyle(fontSize: 44 * 0.43), // to match Apple
              ),
            ),
            onPressed: _signInWithGoogle,
          ),
        ),
        if (!kIsWeb && Platform.isIOS)
          SignInWithAppleButton(
            onPressed: _signInWithApple,
            text: AppLocalizations.of(context)!.signInWithApple,
          )
      ]);
    }
  }

  void _signInWithGoogle() {
    _signInWith((authService) => authService.signInWithGoogle());
  }

  void _signInWithApple() {
    _signInWith((authService) => authService.signInWithApple());
  }

  Future<UserCredential?> _signInWith(Function(AuthService) method) async {
    setState(() => _isLoading = true);

    try {
      await method(context.read<AuthService>());
      // DO NOT setState here: keep showing the loading spinner until the firebaseUser/appUser change

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to sign in: $e"),
      ));
      setState(() => _isLoading = false);
    }
  }
}

class CreateProfileWidget extends StatefulWidget {
  @override
  _CreateProfileWidgetState createState() => _CreateProfileWidgetState();
}

class _CreateProfileWidgetState extends State<CreateProfileWidget> {
  String? _proposedUsername;
  AvatarType? _selectedAvatar;

  bool _isFetchingUsername = false;
  bool _isLoading = false; // TODO do something with this

  @override
  void initState() {
    super.initState();

    _proposeNewUsername();
  }

  @override
  Widget build(BuildContext context) {
    var subtitleTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );

    final firebaseUser =
        context.select((FirebaseService firebase) => firebase.firebaseUser);

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        "Your account has been created.\nPlease complete your profile.",
        textAlign: TextAlign.center,
      ),
      Spacer(),
      Text("Pick an avatar", style: subtitleTextStyle),
      SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (firebaseUser?.photoURL != null)
            SelectableBox(
              child: CircleAvatar(
                radius: defaultAvatarRadius,
                // FIXME this displays black while it loads
                foregroundImage: NetworkImage(firebaseUser!.photoURL!),
              ),
              isSelected: _selectedAvatar == AvatarType.custom,
              onTap: () => setState(() => _selectedAvatar = AvatarType.custom),
            ),
          SelectableBox.iconAvatar(
            icon: AppIcons.chef_hat,
            isSelected: _selectedAvatar == AvatarType.chef_hat,
            onTap: () => setState(() => _selectedAvatar = AvatarType.chef_hat),
          ),
          SelectableBox.iconAvatar(
            icon: AppIcons.salt_and_pepper,
            isSelected: _selectedAvatar == AvatarType.salt_and_pepper,
            onTap: () =>
                setState(() => _selectedAvatar = AvatarType.salt_and_pepper),
          ),
          SelectableBox.iconAvatar(
            icon: AppIcons.food_tray,
            isSelected: _selectedAvatar == AvatarType.food_tray,
            onTap: () => setState(() => _selectedAvatar = AvatarType.food_tray),
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
                _proposedUsername ?? "...",
                style: TextStyle(fontSize: 18),
              ),
            ),
            IconButton(
                splashRadius: 24,
                // TODO figure out how to make the animation finish its current loop no matter when the future completes
                // https://stackoverflow.com/questions/59462290/repeating-animations-specific-times-e-g-20-times-by-flutter
                icon: _isFetchingUsername
                    ? Spinning(child: Icon(Icons.refresh))
                    : Icon(Icons.refresh),
                onPressed: _proposeNewUsername)
          ],
        ),
        isSelected: true,
      ),
      Spacer(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _cancelProfile,
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _selectedAvatar != null ? _completeProfile : null,
            child: Text("Create profile"),
          ),
        ],
      ),
      Spacer(),
    ]);
  }

  Future<void> _proposeNewUsername() async {
    setState(() => _isFetchingUsername = true);

    try {
      final proposedUsername =
          await context.read<FirebaseService>().generateUsername();

      setState(() {
        _isFetchingUsername = false;
        _proposedUsername = proposedUsername;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to generate new username: $e"),
      ));

      setState(() => _isFetchingUsername = false);
    }
  }

  void _cancelProfile() async {
    try {
      await context.read<FirebaseService>().signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to sign out: $e"),
      ));
    }
  }

  Future<void> _completeProfile() async {
    setState(() => _isLoading = true);
    try {
      await context
          .read<FirebaseService>()
          .createProfile(_proposedUsername!, _selectedAvatar!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to create profile: $e"),
      ));
    }
    setState(() => _isLoading = false);
  }
}
