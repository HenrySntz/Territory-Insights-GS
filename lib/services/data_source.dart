import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Fontes de dados: API simulada (água e energia) e API real Open-Meteo (clima).
class DataSource {
  DataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const int days = 30;
  static const String syntheticLabel = 'Dados sintéticos de demonstração (API simulada)';

  DateTime _today(DateTime now) => DateTime(now.year, now.month, now.day);

  /// Simula uma chamada de API com latência.
  Future<Series> fetchSimulated(Metric metric) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return synthetic(metric);
  }

  /// Série determinística de 30 dias, com aumento nos últimos 3 dias para demonstrar alertas.
  Series synthetic(Metric metric, {DateTime? now}) {
    final today = _today(now ?? DateTime.now());
    final rnd = Random(metric.index * 97 + 13);
    final isWater = metric == Metric.water;
    final base = isWater ? 175.0 : 7.5;
    final spike = isWater ? 0.28 : 0.18;
    final points = <DataPoint>[];
    for (var i = days - 1; i >= 0; i--) {
      final date = DateTime(today.year, today.month, today.day - i);
      final weekend = date.weekday >= 6 ? 1.06 : 1.0;
      var value = base * weekend + (rnd.nextDouble() - 0.5) * 2 * base * 0.04;
      if (i < 3) value += base * spike;
      points.add(DataPoint(date, value));
    }
    return Series(metric: metric, points: points, source: syntheticLabel);
  }

  /// Temperatura máxima diária (14 dias passados + 7 de previsão) para São Paulo.
  Future<Series> fetchClimate({DateTime? now}) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '-23.55',
      'longitude': '-46.63',
      'daily': 'temperature_2m_max',
      'past_days': '14',
      'forecast_days': '7',
      'timezone': 'America/Sao_Paulo',
    });
    final response = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final daily = (jsonDecode(response.body) as Map<String, dynamic>)['daily'] as Map<String, dynamic>;
    final times = (daily['time'] as List).cast<String>();
    final temps = daily['temperature_2m_max'] as List;
    final today = _today(now ?? DateTime.now());
    final points = <DataPoint>[];
    for (var i = 0; i < times.length; i++) {
      final temp = temps[i];
      if (temp == null) continue;
      final date = DateTime.parse(times[i]);
      points.add(DataPoint(date, (temp as num).toDouble(), forecast: date.isAfter(today)));
    }
    if (points.isEmpty) throw Exception('Resposta vazia');
    return Series(metric: Metric.climate, points: points, source: 'Open-Meteo (dados reais)', isReal: true);
  }

  /// Plano B de clima quando não há conexão nem cache.
  Series syntheticClimate({DateTime? now}) {
    final today = _today(now ?? DateTime.now());
    final points = <DataPoint>[];
    for (var d = -14; d <= 7; d++) {
      final date = DateTime(today.year, today.month, today.day + d);
      final value = 27 + 2 * sin(d / 3) + (d >= 3 ? 3.5 : 0);
      points.add(DataPoint(date, value, forecast: d > 0));
    }
    return Series(metric: Metric.climate, points: points, source: 'Dados sintéticos (sem conexão)');
  }
}
