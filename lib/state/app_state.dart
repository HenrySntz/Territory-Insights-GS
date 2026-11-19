import 'dart:math';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/alert_engine.dart';
import '../services/data_source.dart';
import '../services/storage.dart';

enum LoadStatus { loading, ready, error }

/// Estado global compartilhado entre as telas (dados, alertas, preferências).
class AppState extends ChangeNotifier {
  AppState(this._storage, this._source)
      : consent = _storage.consent,
        thresholds = _storage.thresholds,
        occurrences = _storage.occurrences,
        decisions = _storage.decisions,
        themeMode = _storage.themeMode,
        textScale = _storage.textScale,
        highContrast = _storage.highContrast;

  final Storage _storage;
  final DataSource _source;

  /// População e domicílios do bairro fictício usados nas estimativas de impacto.
  static const int population = 4800;
  static const int households = 1200;

  LoadStatus status = LoadStatus.loading;
  String? errorMessage;
  bool offline = false;
  DateTime? updatedAt;

  Map<Metric, Series> series = {};
  List<TerritoryAlert> alerts = [];

  bool consent;
  Thresholds thresholds;
  List<Occurrence> occurrences;
  Map<String, HumanDecision> decisions;
  ThemeMode themeMode;
  double textScale;
  bool highContrast;

  TerritoryAlert? alertById(String id) => alerts.where((a) => a.id == id).firstOrNull;

  /// Estimativa de água em risco de desperdício (L/dia) a partir do desvio recente.
  double get waterAtRiskLitersPerDay {
    final st = AlertEngine.stats(series[Metric.water]);
    if (st == null) return 0;
    return max(0.0, st.recent - st.baseline) * population;
  }

  Future<void> load() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _source.fetchSimulated(Metric.water),
        _source.fetchSimulated(Metric.energy),
      ]);
      Series climate;
      try {
        climate = await _source.fetchClimate();
        offline = false;
      } catch (_) {
        offline = true;
        climate = _storage.cachedSeries?[Metric.climate] ?? _source.syntheticClimate();
      }
      series = {
        Metric.water: results[0],
        Metric.energy: results[1],
        Metric.climate: climate,
      };
      await _storage.cacheSeries(series);
      updatedAt = DateTime.now();
      _recompute();
      status = LoadStatus.ready;
    } catch (_) {
      status = LoadStatus.error;
      errorMessage = 'Não foi possível carregar os dados do território.';
    }
    notifyListeners();
  }

  void _recompute() {
    alerts = AlertEngine.generate(series, thresholds);
  }

  Future<void> setConsent(bool value) async {
    consent = value;
    await _storage.setConsent(value);
    notifyListeners();
  }

  Future<void> setThresholds(Thresholds value) async {
    thresholds = value;
    _recompute();
    notifyListeners();
    await _storage.saveThresholds(value);
  }

  Future<void> addOccurrence(Occurrence occurrence) async {
    occurrences = [occurrence, ...occurrences];
    notifyListeners();
    await _storage.saveOccurrences(occurrences);
  }

  Future<void> removeOccurrence(String id) async {
    occurrences = occurrences.where((o) => o.id != id).toList();
    notifyListeners();
    await _storage.saveOccurrences(occurrences);
  }

  Future<void> decide(String alertId, HumanDecision decision) async {
    decisions = {...decisions, alertId: decision};
    notifyListeners();
    await _storage.saveDecisions(decisions);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode = value;
    notifyListeners();
    await _storage.saveThemeMode(value);
  }

  Future<void> setTextScale(double value) async {
    textScale = value;
    notifyListeners();
    await _storage.saveTextScale(value);
  }

  Future<void> setHighContrast(bool value) async {
    highContrast = value;
    notifyListeners();
    await _storage.saveHighContrast(value);
  }

  /// Revoga o consentimento e apaga todos os dados locais.
  Future<void> revokeAndErase() async {
    await _storage.clearAll();
    consent = false;
    thresholds = const Thresholds();
    occurrences = [];
    decisions = {};
    themeMode = ThemeMode.system;
    textScale = 1.0;
    highContrast = false;
    _recompute();
    notifyListeners();
  }
}
