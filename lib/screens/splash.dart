import 'package:flutter/material.dart';

/// Screen shown AFTER Flutter has initialized, while Firebase is still loading
/// the first user. Note that there is another SplashScreen in the Android/iOS
/// layer that gets shown before this one while. It makes sense to keep them in
/// sync for visual continuity.
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
