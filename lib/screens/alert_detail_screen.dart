import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({super.key, required this.alertId});

  final String alertId;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final alert = app.alertById(alertId);
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do alerta')),
      body: alert == null
          ? const StateView.empty(message: 'Alerta não encontrado ou já não está ativo.')
          : _content(context, app, alert),
    );
  }

  Widget _content(BuildContext context, AppState app, TerritoryAlert alert) {
    final text = Theme.of(context).textTheme;
    final current = app.decisions[alert.id];
    return ResponsiveBody(
      child: ListView(
        padding: const EdgeInsets.all(Gap.m),
        children: [
          Row(
            children: [
              Icon(alert.metric.icon, color: alert.metric.color),
              const SizedBox(width: Gap.s),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(alert.title, style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Align(alignment: Alignment.centerLeft, child: SeverityChip(severity: alert.severity)),
          const SizedBox(height: Gap.s),
          Text(alert.summary, style: text.bodyLarge),
          const SectionTitle('Justificativa (evidências)'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [IconBulletList(items: alert.evidence, icon: Icons.fact_check_outlined)],
            ),
          ),
          const SectionTitle('Nível de confiança'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${alert.confidenceLabel} (${(alert.confidence * 100).round()}%)',
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: Gap.s),
                ConfidenceBar(value: alert.confidence, label: alert.confidenceLabel),
              ],
            ),
          ),
          const SectionTitle('Limitações'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [IconBulletList(items: alert.limitations, icon: Icons.warning_amber_rounded, color: Colors.orange.shade800)],
            ),
          ),
          const SizedBox(height: Gap.m),
          const DisclaimerBanner(text: 'Este alerta é apoio à decisão. A decisão final é sempre humana: nenhuma ação é tomada automaticamente.'),
          const SectionTitle('Decisão do gestor'),
          Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [
              for (final d in HumanDecision.values)
                ChoiceChip(
                  label: Text(d.label),
                  selected: current == d,
                  onSelected: (_) {
                    app.decide(alert.id, d);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Decisão registrada: ${d.label}')));
                  },
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          OutlinedButton.icon(
            onPressed: () => context.pushNamed('indicator', pathParameters: {'metric': alert.metric.name}),
            icon: const Icon(Icons.show_chart),
            label: Text('Ver painel de ${alert.metric.label}'),
          ),
        ],
      ),
    );
  }
}
