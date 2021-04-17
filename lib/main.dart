import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/routing/app_route_parser.dart';
import 'package:projectquiche/routing/app_router_delegate.dart';
import 'package:projectquiche/services/auth_service.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/utils/theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseService firebase = FirebaseService();
  AuthService authService = AuthService(firebase);
  AppModel appModel = AppModel(firebase);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: firebase),
      Provider.value(value: authService),
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

    bootstrap();

    super.initState();
  }

  Future<void> bootstrap() async {
    await context.read<FirebaseService>().init();
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

    // const usafaBlue = Color(0xFF26547C);
    // const maximumBlueGreen = Color(0xFF62BEC1);
    // const roseMadder = Color(0xFFDF2935);
    // const lavenderBlush = Color(0xFFEEE5E9);
    // const lavenderBlushDarker = Color(0xFFE6DCDF);
    // const darkSienna = Color(0xFF32161F);
    //
    // var myColorScheme = ColorScheme(
    //   primary: usafaBlue,
    //   primaryVariant: usafaBlue,
    //   secondary: maximumBlueGreen,
    //   secondaryVariant: maximumBlueGreen,
    //   surface: lavenderBlushDarker,
    //   background: lavenderBlush,
    //   error: roseMadder,
    //   onPrimary: Colors.white,
    //   onSecondary: Colors.black,
    //   onSurface: Colors.black,
    //   onBackground: darkSienna,
    //   onError: Colors.black,
    //   brightness: Brightness.light,
    // );

    // Keep it synced with Android (values/colors.xml) and iOS (LaunchScreen.storyboard)
    const mediumSeaGreen = Color(0xFFB71540);
    const redSalsa = Color(0xFFF85A33);
    const blackCoffee = Color(0xFF3A2E39);
    const lightGray = Color(0xFFFFFAFA);
    const isabelline = Color(0xFFF4EDEA);
    // TODO export into AppTheme

    var myColorScheme = ColorScheme(
      primary: mediumSeaGreen,
      primaryVariant: mediumSeaGreen,
      secondary: mediumSeaGreen,
      secondaryVariant: mediumSeaGreen,
      surface: lightGray,
      background: isabelline,
      error: redSalsa,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: blackCoffee,
      onBackground: blackCoffee,
      onError: blackCoffee,
      brightness: Brightness.light,
    );

    return MaterialApp.router(
      routeInformationParser: routeParser,
      routerDelegate: routerDelegate,
      theme: myColorScheme.toTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
