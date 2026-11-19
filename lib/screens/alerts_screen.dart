import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/alert_card.dart';
import '../widgets/common.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas preditivos')),
      body: switch (app.status) {
        LoadStatus.loading => const StateView.loading(),
        LoadStatus.error => StateView.error(message: app.errorMessage ?? 'Erro ao carregar.', onRetry: app.load),
        LoadStatus.ready => app.alerts.isEmpty
            ? const StateView.empty(
                message: 'Nenhum alerta no momento.\nOs indicadores estão dentro dos limiares configurados.',
                icon: Icons.check_circle_outline,
              )
            : ResponsiveBody(
                child: ListView(
                  padding: const EdgeInsets.all(Gap.m),
                  children: [
                    const DisclaimerBanner(),
                    const SizedBox(height: Gap.m),
                    for (final alert in app.alerts) ...[
                      AlertCard(alert: alert, decision: app.decisions[alert.id]),
                      const SizedBox(height: Gap.s),
                    ],
                  ],
                ),
              ),
      },
    );
  }
}
