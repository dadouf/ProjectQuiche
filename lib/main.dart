import 'dart:async';

import 'package:flutter/material.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/routing/app_route_parser.dart';
import 'package:projectquiche/routing/app_router_delegate.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseService firebase = FirebaseService();
  AppModel appModel = AppModel(firebase);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: firebase),
      ChangeNotifierProvider.value(value: appModel),
    ],
    child: QuicheApp(),
  ));
}

class QuicheApp extends StatefulWidget {
  @override
  _QuicheAppState createState() => _QuicheAppState();
}

class _QuicheAppState extends State<QuicheApp> {
  AppRouteParser routeParser = AppRouteParser();
  late AppRouterDelegate routerDelegate;

  @override
  void initState() {
    routerDelegate = AppRouterDelegate(context.read<AppModel>());

    _bootstrap();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFFE06E61);
    var baseTheme = ThemeData.dark();

    return MaterialApp.router(
      routeInformationParser: routeParser,
      routerDelegate: routerDelegate,
      theme: baseTheme.copyWith(
        indicatorColor: mainColor,
        accentColor: mainColor,
        colorScheme: baseTheme.colorScheme.copyWith(secondary: mainColor),
      ),
    );
  }

  void _bootstrap() async {
    await context.read<FirebaseService>().init();
    context.read<AppModel>().onBootstrapComplete();
  }
}
