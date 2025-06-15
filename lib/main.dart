import 'package:admin_panel/data/models/parking_zone_detailed.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'di/injection.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/add_zone_page.dart';
import 'presentation/pages/edit_zone_page.dart';
import 'presentation/pages/manage_zone_details_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  setupDi();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LoginPage()),
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/add-zone',
          builder: (context, state) => const AddZonePage(),
        ),
        GoRoute(
          path: '/edit-zone/:id',
          builder: (context, state) {
            final zone = state.extra as ParkingZoneDetailed;
            return EditZonePage(zone: zone);
          },
        ),
        GoRoute(
          path: '/manage-zone-details/:zoneId',
          builder: (context, state) {
            final zoneId = int.parse(state.pathParameters['zoneId']!);
            return ManageZoneDetailsPage(zoneId: zoneId);
          },
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('ru', 'RU')],
      routerConfig: router,
      title: 'Админ-панель',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
