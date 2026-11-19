import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Persistência local (funciona offline): consentimento, limiares, ocorrências,
/// decisões humanas, preferências visuais e cache das séries.
class Storage {
  Storage(this._prefs);

  final SharedPreferences _prefs;

  static Future<Storage> open() async => Storage(await SharedPreferences.getInstance());

  static const _kConsent = 'consent';
  static const _kThresholds = 'thresholds';
  static const _kOccurrences = 'occurrences';
  static const _kDecisions = 'decisions';
  static const _kSeries = 'series_cache';
  static const _kTheme = 'theme_mode';
  static const _kScale = 'text_scale';
  static const _kContrast = 'high_contrast';

  bool get consent => _prefs.getBool(_kConsent) ?? false;
  Future<void> setConsent(bool value) => _prefs.setBool(_kConsent, value);

  Thresholds get thresholds {
    final raw = _prefs.getString(_kThresholds);
    if (raw == null) return const Thresholds();
    try {
      return Thresholds.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const Thresholds();
    }
  }

  Future<void> saveThresholds(Thresholds value) => _prefs.setString(_kThresholds, jsonEncode(value.toJson()));

  List<Occurrence> get occurrences {
    final raw = _prefs.getString(_kOccurrences);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).map((e) => Occurrence.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveOccurrences(List<Occurrence> value) =>
      _prefs.setString(_kOccurrences, jsonEncode(value.map((o) => o.toJson()).toList()));

  Map<String, HumanDecision> get decisions {
    final raw = _prefs.getString(_kDecisions);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, HumanDecision.values.byName(v as String)));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveDecisions(Map<String, HumanDecision> value) =>
      _prefs.setString(_kDecisions, jsonEncode(value.map((k, v) => MapEntry(k, v.name))));

  Map<Metric, Series>? get cachedSeries {
    final raw = _prefs.getString(_kSeries);
    if (raw == null) return null;
    try {
      final list = (jsonDecode(raw) as List).map((e) => Series.fromJson(e as Map<String, dynamic>));
      return {for (final s in list) s.metric: s};
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheSeries(Map<Metric, Series> value) =>
      _prefs.setString(_kSeries, jsonEncode(value.values.map((s) => s.toJson()).toList()));

  ThemeMode get themeMode {
    final name = _prefs.getString(_kTheme);
    return ThemeMode.values.asNameMap()[name] ?? ThemeMode.system;
  }

  Future<void> saveThemeMode(ThemeMode value) => _prefs.setString(_kTheme, value.name);

  double get textScale => _prefs.getDouble(_kScale) ?? 1.0;
  Future<void> saveTextScale(double value) => _prefs.setDouble(_kScale, value);

  bool get highContrast => _prefs.getBool(_kContrast) ?? false;
  Future<void> saveHighContrast(bool value) => _prefs.setBool(_kContrast, value);

  Future<void> clearAll() => _prefs.clear();
}
