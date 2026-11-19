import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/format.dart';
import '../models/models.dart';

/// Gráfico do indicador: barras para energia, linhas (com previsão tracejada) para água e clima.
class MetricChart extends StatelessWidget {
  const MetricChart({super.key, required this.series, this.threshold});

  final Series series;
  final double? threshold;

  @override
  Widget build(BuildContext context) {
    final points = series.points;
    if (points.isEmpty) return const SizedBox.shrink();
    final color = series.metric.color;
    final small = Theme.of(context).textTheme.bodySmall;
    final dateFmt = DateFormat('dd/MM');
    final values = points.map((p) => p.value).toList();
    var minV = values.reduce(min);
    var maxV = values.reduce(max);
    if (threshold != null) {
      minV = min(minV, threshold!);
      maxV = max(maxV, threshold!);
    }
    final pad = (maxV - minV) * 0.15 + 1;

    final titles = FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(0), style: small),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 7,
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= points.length) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(dateFmt.format(points[i].date), style: small),
            );
          },
        ),
      ),
    );

    final extra = ExtraLinesData(
      horizontalLines: [
        if (threshold != null)
          HorizontalLine(y: threshold!, color: Colors.red.shade700, strokeWidth: 1.5, dashArray: [6, 4]),
      ],
    );

    final Widget chart;
    if (series.metric == Metric.energy) {
      chart = BarChart(
        BarChartData(
          minY: 0,
          maxY: maxV + pad,
          titlesData: titles,
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          extraLinesData: extra,
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].value,
                    width: 6,
                    color: threshold != null && points[i].value > threshold! ? Colors.red.shade700 : color,
                  ),
                ],
              ),
          ],
        ),
      );
    } else {
      final history = <FlSpot>[];
      final forecast = <FlSpot>[];
      for (var i = 0; i < points.length; i++) {
        final spot = FlSpot(i.toDouble(), points[i].value);
        if (points[i].forecast) {
          if (forecast.isEmpty && history.isNotEmpty) forecast.add(history.last);
          forecast.add(spot);
        } else {
          history.add(spot);
        }
      }
      LineChartBarData line(List<FlSpot> spots, {bool dashed = false}) => LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dashArray: dashed ? [6, 5] : null,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: !dashed, color: color.withAlpha(40)),
          );
      chart = LineChart(
        LineChartData(
          minY: minV - pad,
          maxY: maxV + pad,
          titlesData: titles,
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          extraLinesData: extra,
          lineBarsData: [line(history), if (forecast.isNotEmpty) line(forecast, dashed: true)],
        ),
      );
    }

    final unit = series.metric.unit;
    return Semantics(
      label: 'Gráfico de ${series.metric.label}. Mínimo ${fmt(minV)} $unit, máximo ${fmt(maxV)} $unit, '
          'último valor ${fmt(series.latest ?? 0)} $unit.',
      child: ExcludeSemantics(child: SizedBox(height: 240, child: chart)),
    );
  }
}
