import 'dart:math';

/// Formata número com vírgula decimal (pt-BR).
String fmt(double value, [int digits = 1]) => value.toStringAsFixed(digits).replaceAll('.', ',');

double mean(List<double> values) =>
    values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

double stdDev(List<double> values) {
  if (values.length < 2) return 0;
  final m = mean(values);
  final variance = values.map((x) => (x - m) * (x - m)).reduce((a, b) => a + b) / values.length;
  return sqrt(variance);
}
