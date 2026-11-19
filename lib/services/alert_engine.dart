import 'package:intl/intl.dart';

import '../core/format.dart';
import '../models/models.dart';

class WindowStats {
  const WindowStats({
    required this.baseline,
    required this.std,
    required this.recent,
    required this.baselineCount,
  });

  final double baseline;
  final double std;
  final double recent;
  final int baselineCount;

  double get deltaPct => baseline == 0 ? 0 : (recent - baseline) / baseline * 100;
  double get z => std == 0 ? 0 : (recent - baseline) / std;
  double get cv => baseline == 0 ? 0 : std / baseline;
}

/// Gera alertas a partir de regras estatísticas simples e explicáveis.
abstract final class AlertEngine {
  static const int recentDays = 3;

  /// Compara a média dos últimos 3 dias com a média (e desvio) dos dias anteriores.
  static WindowStats? stats(Series? series) {
    if (series == null) return null;
    final values = series.history.map((p) => p.value).toList();
    if (values.length < recentDays + 7) return null;
    final recent = values.sublist(values.length - recentDays);
    final baseline = values.sublist(0, values.length - recentDays);
    return WindowStats(
      baseline: mean(baseline),
      std: stdDev(baseline),
      recent: mean(recent),
      baselineCount: baseline.length,
    );
  }

  static List<TerritoryAlert> generate(
    Map<Metric, Series> series,
    Thresholds thresholds, {
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final alerts = <TerritoryAlert?>[
      _consumption(series[Metric.water], thresholds.waterPct, clock),
      _consumption(series[Metric.energy], thresholds.energyPct, clock),
      _heat(series[Metric.climate], thresholds.heatC, clock),
    ].whereType<TerritoryAlert>().toList();
    alerts.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return alerts;
  }

  static double _confidence(WindowStats st) {
    final sample = (st.baselineCount / 21).clamp(0.0, 1.0);
    final noise = (0.95 - st.cv * 2.5).clamp(0.3, 0.9);
    return noise * (0.7 + 0.3 * sample);
  }

  static TerritoryAlert? _consumption(Series? series, double thresholdPct, DateTime now) {
    final st = stats(series);
    if (series == null || st == null || st.deltaPct < thresholdPct) return null;
    final metric = series.metric;
    final isWater = metric == Metric.water;
    final unit = metric.unit;
    return TerritoryAlert(
      id: '${metric.name}-${DateFormat('yyyyMMdd').format(now)}',
      metric: metric,
      severity: st.deltaPct >= thresholdPct * 1.5 ? Severity.high : Severity.medium,
      title: isWater ? 'Possível desperdício de água' : 'Pico anormal de consumo de energia',
      summary: 'A média dos últimos ${AlertEngine.recentDays} dias está ${fmt(st.deltaPct)}% acima da média '
          'dos ${st.baselineCount} dias anteriores.',
      evidence: [
        'Média recente (${AlertEngine.recentDays} dias): ${fmt(st.recent)} $unit',
        'Média de referência (${st.baselineCount} dias): ${fmt(st.baseline)} $unit',
        'Desvio: +${fmt(st.deltaPct)}% (z = ${fmt(st.z)})',
        'Limiar configurado: ${fmt(thresholdPct, 0)}%',
      ],
      confidence: _confidence(st),
      limitations: [
        'Baseado em apenas ${series.history.length} dias de histórico; não captura sazonalidade anual.',
        if (isWater)
          'Não distingue vazamento de aumento legítimo de uso (visitas, obras, eventos).'
        else
          'Não distingue falha de medição de aumento legítimo de uso (calor, novos equipamentos).',
        if (!series.isReal) 'Dados sintéticos de demonstração, agregados por bairro.',
        'Menos confiável com poucos dados, lacunas ou sensores com falha.',
      ],
      createdAt: now,
    );
  }

  static TerritoryAlert? _heat(Series? series, double heatC, DateTime now) {
    if (series == null) return null;
    final hot = series.points.where((p) => p.forecast && p.value >= heatC).toList();
    if (hot.isEmpty) return null;
    final peak = hot.reduce((a, b) => a.value >= b.value ? a : b);
    final today = DateTime(now.year, now.month, now.day);
    final horizon = peak.date.difference(today).inDays.clamp(1, 7);
    final day = DateFormat('dd/MM').format(peak.date);
    return TerritoryAlert(
      id: 'climate-${DateFormat('yyyyMMdd').format(peak.date)}',
      metric: Metric.climate,
      severity: peak.value >= heatC + 3 ? Severity.high : Severity.medium,
      title: 'Previsão de calor intenso',
      summary: 'Máxima prevista de ${fmt(peak.value)} °C em $day, acima do limiar de ${fmt(heatC, 0)} °C.',
      evidence: [
        'Pico previsto: ${fmt(peak.value)} °C em $day',
        'Dias previstos acima do limiar: ${hot.length}',
        'Limiar configurado: ${fmt(heatC, 0)} °C',
        'Horizonte da previsão: $horizon ${horizon == 1 ? 'dia' : 'dias'}',
      ],
      confidence: (0.9 - 0.08 * horizon).clamp(0.3, 0.9),
      limitations: [
        'A precisão da previsão cai com o horizonte ($horizon ${horizon == 1 ? 'dia' : 'dias'}).',
        'Representa um ponto da cidade; microclimas e ilhas de calor locais podem diferir.',
        'Não considera umidade nem sensação térmica.',
        if (!series.isReal) 'Dados sintéticos usados por falta de conexão.',
      ],
      createdAt: now,
    );
  }
}
