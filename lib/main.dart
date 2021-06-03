import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/models/user_data_model.dart';
import 'package:projectquiche/routing/app_route_parser.dart';
import 'package:projectquiche/routing/app_router_delegate.dart';
import 'package:projectquiche/services/auth_service.dart';
import 'package:projectquiche/services/error_reporting_service.dart';
import 'package:projectquiche/services/firebase/firebase_service.dart';
import 'package:projectquiche/ui/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorReportingService errorReportingService = ErrorReportingService();
  FirebaseService firebase = FirebaseService(errorReportingService);
  AuthService authService = AuthService(firebase, errorReportingService);
  AppModel appModel = AppModel(firebase);
  UserDataModel userDataModel =
      UserDataModel(appModel, firebase, errorReportingService);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: firebase),
      Provider.value(value: authService),
      ChangeNotifierProvider.value(value: appModel),
      ChangeNotifierProvider.value(value: userDataModel),
      Provider.value(value: errorReportingService),
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
    return MaterialApp.router(
      routeInformationParser: routeParser,
      routerDelegate: routerDelegate,
      theme: AppTheme.colorScheme.toTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
