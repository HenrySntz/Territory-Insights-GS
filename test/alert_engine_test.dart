import 'package:flutter_test/flutter_test.dart';
import 'package:territory_insights/models/models.dart';
import 'package:territory_insights/services/alert_engine.dart';

Series consumption(Metric metric, List<double> values) => Series(
      metric: metric,
      source: 'teste',
      points: [for (var i = 0; i < values.length; i++) DataPoint(DateTime(2026, 10, 1 + i), values[i])],
    );

Series climate(int peakInDays) {
  final now = DateTime(2026, 11, 18);
  return Series(
    metric: Metric.climate,
    source: 'teste',
    points: [
      for (var d = -14; d <= 7; d++)
        DataPoint(
          DateTime(now.year, now.month, now.day + d),
          d == peakInDays ? 35 : 27,
          forecast: d > 0,
        ),
    ],
  );
}

void main() {
  final now = DateTime(2026, 11, 18);

  test('gera alerta de consumo quando a média recente passa do limiar', () {
    final values = <double>[...List.filled(27, 100.0), 130, 130, 130];
    final alerts = AlertEngine.generate({Metric.water: consumption(Metric.water, values)}, const Thresholds(), now: now);
    expect(alerts, hasLength(1));
    expect(alerts.first.metric, Metric.water);
    expect(alerts.first.severity, Severity.high);
    expect(alerts.first.confidence, inInclusiveRange(0, 1));
    expect(alerts.first.limitations, isNotEmpty);
    expect(alerts.first.evidence, isNotEmpty);
  });

  test('não gera alerta com consumo estável', () {
    final alerts = AlertEngine.generate(
      {Metric.energy: consumption(Metric.energy, List.filled(30, 8.0))},
      const Thresholds(),
      now: now,
    );
    expect(alerts, isEmpty);
  });

  test('não gera alerta com poucos dados', () {
    final alerts = AlertEngine.generate(
      {Metric.water: consumption(Metric.water, [100, 100, 150])},
      const Thresholds(),
      now: now,
    );
    expect(alerts, isEmpty);
  });

  test('gera alerta de calor e a confiança cai com o horizonte', () {
    final near = AlertEngine.generate({Metric.climate: climate(1)}, const Thresholds(), now: now).single;
    final far = AlertEngine.generate({Metric.climate: climate(6)}, const Thresholds(), now: now).single;
    expect(near.metric, Metric.climate);
    expect(near.confidence, greaterThan(far.confidence));
  });
}
