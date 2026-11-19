import 'package:flutter/material.dart';
import '../models/models.dart';

abstract final class Gap {
  static const double s = 10;
  static const double m = 18;
  static const double l = 26;
}

InputDecoration fieldDecoration(String label, {String? hint, String? helper}) => InputDecoration(
  labelText: label, hintText: hint, helperText: helper, helperMaxLines: 3,
  prefixIcon: const Icon(Icons.tune_rounded, size: 19),
);

class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1040), child: child),
  );
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.semanticLabel, this.padding = const EdgeInsets.all(Gap.m)});
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true, button: onTap != null, label: semanticLabel, excludeSemantics: semanticLabel != null,
    child: Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : const Color(0xFFE5ECEF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 12),
      child: Row(children: [Expanded(child: Text(text, style: Theme.of(context).textTheme.titleLarge)), if (trailing != null) trailing!]),
    ),
  );
}

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key, this.text = 'Os alertas apoiam, mas não substituem, a decisão humana.'});
  final String text;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: cs.primaryContainer.withAlpha(150), borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.primary.withAlpha(35))),
      child: Row(children: [Icon(Icons.shield_outlined, color: cs.primary), const SizedBox(width: 12), Expanded(child: Text(text, style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w600, fontSize: 12)))]),
    );
  }
}

class NoticeBanner extends StatelessWidget {
  const NoticeBanner({super.key, required this.text, this.icon = Icons.cloud_off_outlined});
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(icon, color: cs.onTertiaryContainer), const SizedBox(width: 12), Expanded(child: Text(text, style: TextStyle(color: cs.onTertiaryContainer)))]));
  }
}

class StateView extends StatelessWidget {
  const StateView.loading({super.key, this.message = 'Preparando os dados do território...'}) : loading = true, icon = null, onRetry = null;
  const StateView.error({super.key, required this.message, required this.onRetry}) : loading = false, icon = Icons.cloud_off_outlined;
  const StateView.empty({super.key, required this.message, this.icon = Icons.inbox_outlined}) : loading = false, onRetry = null;
  final bool loading; final String message; final IconData? icon; final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 76, height: 76, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle), child: Center(child: loading ? const CircularProgressIndicator() : Icon(icon, size: 34, color: Theme.of(context).colorScheme.primary))),
    const SizedBox(height: 20), Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
    if (onRetry != null) ...[const SizedBox(height: 20), FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Tentar novamente'))],
  ])));
}

class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar({super.key, required this.value, required this.label});
  final double value; final String label;
  @override
  Widget build(BuildContext context) => Semantics(label: 'Nível de confiança $label, ${(value * 100).round()} por cento', excludeSemantics: true, child: TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: value), duration: const Duration(milliseconds: 700), builder: (context, v, _) => ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: v, minHeight: 9))));
}

class SeverityChip extends StatelessWidget {
  const SeverityChip({super.key, required this.severity}); final Severity severity;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: severity.color.withAlpha(18), borderRadius: BorderRadius.circular(9), border: Border.all(color: severity.color.withAlpha(70))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, color: severity.color, size: 7), const SizedBox(width: 7), Text(severity.label, style: TextStyle(color: severity.color, fontWeight: FontWeight.w700, fontSize: 11))]));
}

class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.icon, required this.value, required this.label});
  final IconData icon; final String value; final String label;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(container: true, label: '$label: $value', excludeSemantics: true, child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withAlpha(130), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: Theme.of(context).colorScheme.primary)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)), Text(label, style: text.bodySmall)]))])));
  }
}

/// Lista de itens com ícone (evidências, limitações, regras de privacidade).
class IconBulletList extends StatelessWidget {
  const IconBulletList({super.key, required this.items, required this.icon, this.color});

  final List<String> items;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 18, color: tint)),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Selo pequeno de texto (ex.: categoria, fonte de dados).
class InfoPill extends StatelessWidget {
  const InfoPill({super.key, required this.text, required this.icon, this.color});

  final String text;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: tint.withAlpha(24), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: tint),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: TextStyle(color: tint, fontSize: 12, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
