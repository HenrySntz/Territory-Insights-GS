import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'models/models.dart';
import 'screens/alert_detail_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/consent_screen.dart';
import 'screens/home_screen.dart';
import 'screens/indicator_screen.dart';
import 'screens/occurrence_form_screen.dart';
import 'screens/occurrences_screen.dart';
import 'screens/settings_screen.dart';
import 'state/app_state.dart';
import 'widgets/app_shell.dart';

GoRouter buildRouter(AppState app) {
  return GoRouter(
    refreshListenable: app,
    initialLocation: '/',
    redirect: (context, state) {
      final atConsent = state.matchedLocation == '/consent';
      if (!app.consent) return atConsent ? null : '/consent';
      if (atConsent) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/consent',
        name: 'consent',
        builder: (context, state) => const ConsentScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'indicator/:metric',
                name: 'indicator',
                builder: (context, state) {
                  final metric = Metric.values.asNameMap()[state.pathParameters['metric']] ?? Metric.water;
                  return IndicatorScreen(metric: metric);
                },
              ),
              GoRoute(
                path: 'alerts',
                name: 'alerts',
                builder: (context, state) => const AlertsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'alert-detail',
                    builder: (context, state) => AlertDetailScreen(alertId: state.pathParameters['id'] ?? ''),
                  ),
                ],
              ),
              GoRoute(
                path: 'occurrences',
                name: 'occurrences',
                builder: (context, state) => const OccurrencesScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'occurrence-new',
                    builder: (context, state) => const OccurrenceFormScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class TerritoryApp extends StatefulWidget {
  const TerritoryApp({super.key, required this.state});

  final AppState state;

  @override
  State<TerritoryApp> createState() => _TerritoryAppState();
}

class _TerritoryAppState extends State<TerritoryApp> {
  late final GoRouter _router = buildRouter(widget.state);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return MaterialApp.router(
      title: 'Territory Insights',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light(highContrast: app.highContrast),
      darkTheme: AppTheme.dark(highContrast: app.highContrast),
      themeMode: app.themeMode,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final factor = mq.textScaler.scale(1) * app.textScale;
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(factor)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
