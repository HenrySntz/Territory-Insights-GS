import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import 'common.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.alert, this.decision});
  final TerritoryAlert alert;
  final HumanDecision? decision;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final severityColor = alert.severity.color;
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.pushNamed('alert-detail', pathParameters: {'id': alert.id}),
      semanticLabel: '${alert.title}. ${alert.severity.label}. Confiança ${alert.confidenceLabel}. ${decision == null ? 'Aguardando decisão humana.' : 'Decisão: ${decision!.label}.'} Toque para ver detalhes.',
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: severityColor, width: 5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(alert.metric.icon, color: alert.metric.color, size: 18), const SizedBox(width: 8), Expanded(child: Text(alert.metric.label.toUpperCase(), style: text.bodySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: .8, fontSize: 11))), SeverityChip(severity: alert.severity)]),
          const SizedBox(height: 12),
          Text(alert.title, style: text.titleMedium?.copyWith(fontSize: 16)),
          const SizedBox(height: 5),
          Text(alert.summary, maxLines: 3, overflow: TextOverflow.ellipsis, style: text.bodyMedium),
          const SizedBox(height: 14),
          Row(children: [Text('CONFIANÇA', style: text.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .7)), const Spacer(), Text('${(alert.confidence * 100).round()}% · ${alert.confidenceLabel}', style: text.bodySmall?.copyWith(fontWeight: FontWeight.w800))]),
          const SizedBox(height: 7),
          ConfidenceBar(value: alert.confidence, label: alert.confidenceLabel),
          const SizedBox(height: 12),
          Row(children: [Icon(decision == null ? Icons.pending_outlined : Icons.task_alt_rounded, size: 16, color: decision == null ? Colors.orange.shade800 : Colors.green.shade700), const SizedBox(width: 6), Expanded(child: Text(decision == null ? 'Aguardando avaliação humana' : decision!.label, style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600))), const Icon(Icons.arrow_forward_rounded, size: 17)]),
        ]),
      ),
    );
  }
}
