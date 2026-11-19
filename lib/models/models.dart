import 'package:flutter/material.dart';

import '../core/format.dart';

enum Metric { water, energy, climate }

extension MetricX on Metric {
  String get label => switch (this) {
        Metric.water => 'Água',
        Metric.energy => 'Energia',
        Metric.climate => 'Clima',
      };

  String get unit => switch (this) {
        Metric.water => 'L/hab/dia',
        Metric.energy => 'kWh/dom/dia',
        Metric.climate => '°C',
      };

  String get description => switch (this) {
        Metric.water => 'Consumo médio de água por habitante',
        Metric.energy => 'Consumo médio de energia por domicílio',
        Metric.climate => 'Temperatura máxima diária (histórico e previsão)',
      };

  IconData get icon => switch (this) {
        Metric.water => Icons.water_drop_outlined,
        Metric.energy => Icons.bolt_outlined,
        Metric.climate => Icons.thermostat_outlined,
      };

  Color get color => switch (this) {
        Metric.water => Colors.blue.shade700,
        Metric.energy => Colors.amber.shade900,
        Metric.climate => Colors.deepOrange.shade700,
      };
}

enum Severity { medium, high }

extension SeverityX on Severity {
  String get label => this == Severity.high ? 'Severidade alta' : 'Severidade média';

  Color get color => this == Severity.high ? Colors.red.shade800 : Colors.orange.shade900;
}

enum HumanDecision { dispatch, monitor, dismiss }

extension HumanDecisionX on HumanDecision {
  String get label => switch (this) {
        HumanDecision.dispatch => 'Acionar equipe técnica',
        HumanDecision.monitor => 'Manter em monitoramento',
        HumanDecision.dismiss => 'Descartar alerta',
      };
}

class DataPoint {
  const DataPoint(this.date, this.value, {this.forecast = false});

  final DateTime date;
  final double value;
  final bool forecast;

  Map<String, dynamic> toJson() => {'d': date.toIso8601String(), 'v': value, 'f': forecast};

  factory DataPoint.fromJson(Map<String, dynamic> json) => DataPoint(
        DateTime.parse(json['d'] as String),
        (json['v'] as num).toDouble(),
        forecast: json['f'] as bool? ?? false,
      );
}

class Series {
  const Series({
    required this.metric,
    required this.points,
    required this.source,
    this.isReal = false,
  });

  final Metric metric;
  final List<DataPoint> points;
  final String source;
  final bool isReal;

  List<DataPoint> get history => points.where((p) => !p.forecast).toList();

  double? get latest => history.isEmpty ? null : history.last.value;

  /// Variação percentual da média dos últimos 7 dias contra os 7 anteriores.
  double? get trendPct {
    final values = history.map((p) => p.value).toList();
    if (values.length < 14) return null;
    final recent = mean(values.sublist(values.length - 7));
    final previous = mean(values.sublist(values.length - 14, values.length - 7));
    return previous == 0 ? null : (recent - previous) / previous * 100;
  }

  Map<String, dynamic> toJson() => {
        'm': metric.name,
        'p': points.map((p) => p.toJson()).toList(),
        's': source,
        'r': isReal,
      };

  factory Series.fromJson(Map<String, dynamic> json) => Series(
        metric: Metric.values.byName(json['m'] as String),
        points: (json['p'] as List).map((e) => DataPoint.fromJson(e as Map<String, dynamic>)).toList(),
        source: json['s'] as String,
        isReal: json['r'] as bool? ?? false,
      );
}

class Thresholds {
  const Thresholds({this.waterPct = 15, this.energyPct = 15, this.heatC = 32});

  final double waterPct;
  final double energyPct;
  final double heatC;

  Map<String, dynamic> toJson() => {'w': waterPct, 'e': energyPct, 'h': heatC};

  factory Thresholds.fromJson(Map<String, dynamic> json) => Thresholds(
        waterPct: (json['w'] as num).toDouble(),
        energyPct: (json['e'] as num).toDouble(),
        heatC: (json['h'] as num).toDouble(),
      );
}

class TerritoryAlert {
  const TerritoryAlert({
    required this.id,
    required this.metric,
    required this.severity,
    required this.title,
    required this.summary,
    required this.evidence,
    required this.confidence,
    required this.limitations,
    required this.createdAt,
  });

  final String id;
  final Metric metric;
  final Severity severity;
  final String title;
  final String summary;
  final List<String> evidence;
  final double confidence;
  final List<String> limitations;
  final DateTime createdAt;

  String get confidenceLabel => confidence >= 0.75
      ? 'Alta'
      : confidence >= 0.55
          ? 'Média'
          : 'Baixa';
}

class Occurrence {
  const Occurrence({
    required this.id,
    required this.category,
    required this.description,
    required this.location,
    required this.createdAt,
  });

  final String id;
  final String category;
  final String description;
  final String location;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'c': category,
        'd': description,
        'l': location,
        't': createdAt.toIso8601String(),
      };

  factory Occurrence.fromJson(Map<String, dynamic> json) => Occurrence(
        id: json['id'] as String,
        category: json['c'] as String,
        description: json['d'] as String,
        location: json['l'] as String,
        createdAt: DateTime.parse(json['t'] as String),
      );
}
