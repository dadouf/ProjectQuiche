import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:projectquiche/models/app_model.dart';
import 'package:projectquiche/models/user_data_model.dart';
import 'package:projectquiche/routing/app_route_parser.dart';
import 'package:projectquiche/routing/app_router_delegate.dart';
import 'package:projectquiche/services/analytics_service.dart';
import 'package:projectquiche/services/bootstrap_service.dart';
import 'package:projectquiche/services/error_reporting_service.dart';
import 'package:projectquiche/services/identity_service.dart';
import 'package:projectquiche/ui/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppModel appModel = AppModel();

  ErrorReportingService errorReportingService = ErrorReportingService();
  AnalyticsService analyticsService = AnalyticsService();
  IdentityService identityService =
      IdentityService(errorReportingService, analyticsService, appModel);
  BootstrapService firebase =
      BootstrapService(errorReportingService, identityService);
  UserDataModel userDataModel =
      UserDataModel(appModel, firebase, errorReportingService);

  runApp(MultiProvider(
    providers: [
      Provider.value(value: firebase),
      Provider.value(value: identityService),
      ChangeNotifierProvider.value(value: appModel),
      ChangeNotifierProvider.value(value: userDataModel),
      Provider.value(value: errorReportingService),
      Provider.value(value: analyticsService),
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
    await context.read<BootstrapService>().init();
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
