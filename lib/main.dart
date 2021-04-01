import 'dart:async';

import 'package:flutter/material.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/routing/app_route_parser.dart';
import 'package:projectquiche/routing/app_router_delegate.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/utils/theme.dart';
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

    // Bootstrap Firebase
    context.read<FirebaseService>().init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // const darkLiverHorses = Color(0xFF564138);
    // const myrtleGreen = Color(0xFF38726C);
    // const sunglow = Color(0xFFFFC914);
    // const lightPeriwinkle = Color(0xFFC7CCDB);
    // const snow = Color(0xFFFCF7F8);
    // var myColorScheme = ColorScheme(
    //   primary: myrtleGreen,
    //   primaryVariant: myrtleGreen,
    //   secondary: sunglow,
    //   secondaryVariant: sunglow,
    //   surface: lightPeriwinkle,
    //   background: snow,
    //   error: Colors.red,
    //   onPrimary: Colors.white,
    //   onSecondary: Colors.black,
    //   onSurface: Colors.black,
    //   onBackground: Colors.black,
    //   onError: Colors.black,
    //   brightness: Brightness.light,
    // );

    const usafaBlue = Color(0xFF26547C);
    const maximumBlueGreen = Color(0xFF62BEC1);
    const roseMadder = Color(0xFFDF2935);
    const lavenderBlush = Color(0xFFEEE5E9);
    const darkSienna = Color(0xFF32161F);

    var myColorScheme = ColorScheme(
      primary: usafaBlue,
      primaryVariant: usafaBlue,
      secondary: maximumBlueGreen,
      secondaryVariant: maximumBlueGreen,
      surface: lavenderBlush,
      background: lavenderBlush,
      error: roseMadder,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: darkSienna,
      onError: Colors.black,
      brightness: Brightness.light,
    );

    return MaterialApp.router(
      routeInformationParser: routeParser,
      routerDelegate: routerDelegate,
      theme: myColorScheme.toTheme(),
    );
  }
}
