import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

/// Casca de navegação: barra inferior nas telas principais, oculta nas telas de detalhe.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _tabs = <({String path, String label, IconData icon, IconData selectedIcon})>[
    (path: '/', label: 'Início', icon: Icons.space_dashboard_outlined, selectedIcon: Icons.space_dashboard_rounded),
    (path: '/alerts', label: 'Alertas', icon: Icons.notifications_none_rounded, selectedIcon: Icons.notifications_rounded),
    (path: '/occurrences', label: 'Ocorrências', icon: Icons.record_voice_over_outlined, selectedIcon: Icons.record_voice_over_rounded),
    (path: '/settings', label: 'Ajustes', icon: Icons.tune_outlined, selectedIcon: Icons.tune_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final index = _tabs.indexWhere((t) => t.path == location);
    if (index < 0) return child;
    final alertCount = context.select<AppState, int>((a) => a.alerts.length);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: t.path == '/alerts'
                  ? Badge(isLabelVisible: alertCount > 0, label: Text('$alertCount'), child: Icon(t.icon))
                  : Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.label,
              tooltip: t.label,
            ),
        ],
      ),
    );
  }
}
