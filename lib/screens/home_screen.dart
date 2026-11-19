import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/alert_card.dart';
import '../widgets/common.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18, top: 12, bottom: 12),
          child: Container(decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.insights_rounded, color: Colors.white)),
        ),
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TERRITORY INSIGHTS', style: TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w800, color: Color(0xFF087F75))),
          Text('Inteligência territorial'),
        ]),
      ),
      body: switch (app.status) {
        LoadStatus.loading => const StateView.loading(),
        LoadStatus.error => StateView.error(message: app.errorMessage ?? 'Não foi possível carregar os dados.', onRetry: app.load),
        LoadStatus.ready => _Overview(app: app),
      },
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final updated = app.updatedAt == null ? 'Aguardando atualização' : 'Atualizado em ${DateFormat('dd/MM/yyyy · HH:mm').format(app.updatedAt!)}';
    final topAlert = app.alerts.firstOrNull;
    return RefreshIndicator(
      onRefresh: app.load,
      child: ResponsiveBody(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
          children: [
            _HeroPanel(alertCount: app.alerts.length, updated: updated, offline: app.offline),
            const SizedBox(height: 18),
            const DisclaimerBanner(),
            if (app.offline) ...[const SizedBox(height: 12), const NoticeBanner(text: 'Modo offline ativo. Os dados disponíveis vêm do cache local ou de conjuntos sintéticos.')],
            const SectionTitle('Visão geral do território', trailing: _LiveTag()),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth > 640;
              final cardWidth = wide ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                for (final metric in Metric.values)
                  SizedBox(width: cardWidth, child: _MetricCard(metric: metric, series: app.series[metric])),
              ]);
            }),
            SectionTitle('Centro de alertas', trailing: TextButton(onPressed: () => context.pushNamed('alerts'), child: const Text('Ver todos'))),
            if (topAlert == null)
              AppCard(padding: const EdgeInsets.all(20), child: Row(children: [Icon(Icons.check_circle_outline, color: theme.colorScheme.primary, size: 28), const SizedBox(width: 12), const Expanded(child: Text('Nenhum alerta ativo. Os indicadores permanecem dentro dos limiares configurados.'))]))
            else ...[
              AlertCard(alert: topAlert, decision: app.decisions[topAlert.id]),
              if (app.alerts.length > 1) Padding(padding: const EdgeInsets.only(top: 8), child: Text('${app.alerts.length - 1} outro(s) alerta(s) aguardando análise', style: theme.textTheme.bodySmall)),
            ],
            const SectionTitle('Impacto social estimado'),
            AppCard(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Indicadores de benefício para a comunidade', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Estimativas que ajudam a dimensionar os efeitos das condições monitoradas.', style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              StatRow(icon: Icons.water_drop_outlined, value: '${fmt(app.waterAtRiskLitersPerDay / 1000)} mil L/dia', label: 'Água em risco de desperdício · ${AppState.households} domicílios monitorados'),
              const Divider(),
              StatRow(icon: Icons.record_voice_over_outlined, value: '${app.occurrences.length}', label: 'Ocorrências cidadãs registradas de forma anônima'),
              const Divider(),
              StatRow(icon: Icons.fact_check_outlined, value: '${app.decisions.length}', label: 'Decisões humanas registradas sobre alertas'),
            ])),
            const SizedBox(height: 22),
            Row(children: [const Icon(Icons.update_rounded, size: 15), const SizedBox(width: 7), Expanded(child: Text(updated, style: theme.textTheme.bodySmall)), TextButton.icon(onPressed: app.load, icon: const Icon(Icons.refresh, size: 16), label: const Text('Atualizar'))]),
          ],
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.alertCount, required this.updated, required this.offline});
  final int alertCount; final String updated; final bool offline;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF102A43), Color(0xFF087F75)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF102A43).withAlpha(35), blurRadius: 22, offset: const Offset(0, 10))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withAlpha(28), borderRadius: BorderRadius.circular(20)), child: Row(children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: offline ? const Color(0xFFFFC46B) : const Color(0xFF75E0B0), shape: BoxShape.circle)), const SizedBox(width: 7), Text(offline ? 'DADOS EM CACHE' : 'MONITORAMENTO ATIVO', style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w800))])), const Spacer(), const Icon(Icons.public_rounded, color: Colors.white54, size: 27)]),
        const SizedBox(height: 24),
        const Text('Entenda o território.\nAntecipe necessidades.', style: TextStyle(color: Colors.white, fontSize: 27, height: 1.12, fontWeight: FontWeight.w800, letterSpacing: -.7)),
        const SizedBox(height: 10),
        const Text('Dados e tendências para apoiar decisões públicas mais conscientes.', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
        const SizedBox(height: 22),
        Container(height: 1, color: Colors.white24),
        const SizedBox(height: 15),
        Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD28A), size: 20), const SizedBox(width: 8),
          Text('$alertCount ${alertCount == 1 ? 'alerta ativo' : 'alertas ativos'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          const Spacer(), Flexible(child: Text(updated, textAlign: TextAlign.end, style: const TextStyle(color: Colors.white70, fontSize: 11))),
        ]),
      ]),
    );
  }
}

class _LiveTag extends StatelessWidget {
  const _LiveTag();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withAlpha(14), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.analytics_outlined, size: 13, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 5), Text('3 PAINÉIS', style: TextStyle(fontSize: 11, letterSpacing: .7, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary))]));
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric, required this.series});
  final Metric metric; final Series? series;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final latest = series?.latest;
    final trend = series?.trendPct;
    final value = latest == null ? '—' : fmt(latest);
    final trendText = trend == null ? 'Histórico em formação' : '${trend >= 0 ? '+' : '−'}${fmt(trend.abs())}% na semana';
    return AppCard(
      padding: const EdgeInsets.all(17),
      onTap: () => context.pushNamed('indicator', pathParameters: {'metric': metric.name}),
      semanticLabel: '${metric.label}: $value ${metric.unit}. $trendText. Abrir painel.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: metric.color.withAlpha(20), borderRadius: BorderRadius.circular(12)), child: Icon(metric.icon, color: metric.color, size: 21)), const Spacer(), Icon(Icons.north_east_rounded, color: Theme.of(context).colorScheme.outline, size: 17)]),
        const SizedBox(height: 16),
        Text(metric.label.toUpperCase(), style: text.bodySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: .8, fontSize: 11)),
        const SizedBox(height: 5),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
        const SizedBox(height: 2),
        Text(metric.unit, style: text.bodySmall),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: (trend != null && trend > 0 ? const Color(0xFFB65A3C) : const Color(0xFF27866B)).withAlpha(13), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(trend != null && trend > 0 ? Icons.trending_up : Icons.trending_flat, size: 14, color: trend != null && trend > 0 ? const Color(0xFFB65A3C) : const Color(0xFF27866B)), const SizedBox(width: 5), Flexible(child: Text(trendText, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.bodySmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 11)))])),
      ]),
    );
  }
}
