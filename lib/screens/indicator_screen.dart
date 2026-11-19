import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../models/models.dart';
import '../services/alert_engine.dart';
import '../state/app_state.dart';
import '../widgets/alert_card.dart';
import '../widgets/common.dart';
import '../widgets/metric_chart.dart';

/// Dashboard de um indicador (água, energia ou clima), recebido por parâmetro de rota.
class IndicatorScreen extends StatelessWidget {
  const IndicatorScreen({super.key, required this.metric});

  final Metric metric;

  double? _threshold(AppState app, Series series) {
    if (metric == Metric.climate) return app.thresholds.heatC;
    final st = AlertEngine.stats(series);
    if (st == null) return null;
    final pct = metric == Metric.water ? app.thresholds.waterPct : app.thresholds.energyPct;
    return st.baseline * (1 + pct / 100);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final series = app.series[metric];
    return Scaffold(
      appBar: AppBar(title: Text('Painel de ${metric.label}')),
      body: switch (app.status) {
        LoadStatus.loading => const StateView.loading(),
        LoadStatus.error => StateView.error(message: app.errorMessage ?? 'Erro ao carregar.', onRetry: app.load),
        LoadStatus.ready => series == null || series.points.isEmpty
            ? const StateView.empty(message: 'Sem dados para este indicador.')
            : _content(context, app, series),
      },
    );
  }

  Widget _content(BuildContext context, AppState app, Series series) {
    final text = Theme.of(context).textTheme;
    final history = series.history.map((p) => p.value).toList();
    final trend = series.trendPct;
    final alerts = app.alerts.where((a) => a.metric == metric).toList();
    return ResponsiveBody(
      child: ListView(
        padding: const EdgeInsets.all(Gap.m),
        children: [
          AppCard(
            child: Row(
              children: [
                Icon(metric.icon, color: metric.color, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${fmt(series.latest ?? 0)} ${metric.unit}', style: text.headlineSmall),
                      Text(metric.description, style: text.bodySmall),
                      if (trend != null)
                        Text(
                          '${trend >= 0 ? '▲ alta' : '▼ queda'} de ${fmt(trend.abs())}% vs. semana anterior',
                          style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle('Histórico e tendência'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MetricChart(series: series, threshold: _threshold(app, series)),
                const SizedBox(height: Gap.s),
                Text(
                  'Linha tracejada vermelha: limiar de alerta.'
                  '${metric == Metric.climate ? ' Trecho tracejado da curva: previsão.' : ''}',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          const SectionTitle('Resumo do período'),
          AppCard(
            child: Column(
              children: [
                StatRow(icon: Icons.functions, value: '${fmt(mean(history))} ${metric.unit}', label: 'Média'),
                StatRow(
                  icon: Icons.arrow_upward,
                  value: '${fmt(history.reduce((a, b) => a > b ? a : b))} ${metric.unit}',
                  label: 'Máximo',
                ),
                StatRow(
                  icon: Icons.arrow_downward,
                  value: '${fmt(history.reduce((a, b) => a < b ? a : b))} ${metric.unit}',
                  label: 'Mínimo',
                ),
              ],
            ),
          ),
          const SectionTitle('Leitura para o território'),
          _extra(context, series),
          const SizedBox(height: Gap.s),
          Text('Fonte: ${series.source}', style: text.bodySmall),
          const SectionTitle('Alertas deste indicador'),
          if (alerts.isEmpty)
            const AppCard(child: Text('Nenhum alerta para este indicador.'))
          else
            for (final alert in alerts) ...[
              AlertCard(alert: alert, decision: app.decisions[alert.id]),
              const SizedBox(height: Gap.s),
            ],
        ],
      ),
    );
  }

  Widget _extra(BuildContext context, Series series) {
    final latest = series.latest ?? 0;
    switch (metric) {
      case Metric.water:
        return AppCard(
          child: StatRow(
            icon: Icons.apartment_outlined,
            value: '${fmt(latest * AppState.population / 1000)} m³/dia',
            label: 'Volume estimado do bairro (${AppState.population} habitantes)',
          ),
        );
      case Metric.energy:
        return AppCard(
          child: StatRow(
            icon: Icons.home_work_outlined,
            value: '${fmt(latest * AppState.households / 1000)} MWh/dia',
            label: 'Energia estimada do bairro (${AppState.households} domicílios)',
          ),
        );
      case Metric.climate:
        final next = series.points.where((p) => p.forecast).toList();
        return AppCard(
          child: Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [
              for (final p in next)
                Chip(label: Text('${DateFormat('dd/MM').format(p.date)}: ${fmt(p.value, 0)} °C')),
            ],
          ),
        );
    }
  }
}
