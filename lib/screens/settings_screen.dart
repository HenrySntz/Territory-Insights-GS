import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/validators.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _water;
  late final TextEditingController _energy;
  late final TextEditingController _heat;

  @override
  void initState() {
    super.initState();
    final t = context.read<AppState>().thresholds;
    _water = TextEditingController(text: t.waterPct.toStringAsFixed(0));
    _energy = TextEditingController(text: t.energyPct.toStringAsFixed(0));
    _heat = TextEditingController(text: t.heatC.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _water.dispose();
    _energy.dispose();
    _heat.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AppState>().setThresholds(
          Thresholds(
            waterPct: Validators.parseNumber(_water.text)!,
            energyPct: Validators.parseNumber(_energy.text)!,
            heatC: Validators.parseNumber(_heat.text)!,
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Limiares salvos. Alertas recalculados.')));
  }

  Future<void> _erase() async {
    final app = context.read<AppState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar dados e revogar consentimento?'),
        content: const Text('Ocorrências, decisões, limiares e preferências deste aparelho serão apagados.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Apagar')),
        ],
      ),
    );
    if (confirmed == true) await app.revokeAndErase();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    const keyboard = TextInputType.numberWithOptions(decimal: true);
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ResponsiveBody(
        child: ListView(
          padding: const EdgeInsets.all(Gap.m),
          children: [
            const SectionTitle('Limiares de alerta'),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _water,
                    keyboardType: keyboard,
                    decoration: fieldDecoration('Água: aumento tolerado (%)', helper: 'Entre 5 e 100%'),
                    validator: (v) => Validators.numberInRange(v, min: 5, max: 100, unit: '%'),
                  ),
                  const SizedBox(height: Gap.m),
                  TextFormField(
                    controller: _energy,
                    keyboardType: keyboard,
                    decoration: fieldDecoration('Energia: aumento tolerado (%)', helper: 'Entre 5 e 100%'),
                    validator: (v) => Validators.numberInRange(v, min: 5, max: 100, unit: '%'),
                  ),
                  const SizedBox(height: Gap.m),
                  TextFormField(
                    controller: _heat,
                    keyboardType: keyboard,
                    decoration: fieldDecoration('Calor: temperatura máxima (°C)', helper: 'Entre 25 e 45 °C'),
                    validator: (v) => Validators.numberInRange(v, min: 25, max: 45, unit: '°C'),
                  ),
                  const SizedBox(height: Gap.m),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar limiares'),
                    ),
                  ),
                ],
              ),
            ),
            const SectionTitle('Aparência e acessibilidade'),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
                ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Escuro')),
              ],
              selected: {app.themeMode},
              onSelectionChanged: (s) => app.setThemeMode(s.first),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Alto contraste'),
              value: app.highContrast,
              onChanged: app.setHighContrast,
            ),
            const SizedBox(height: Gap.s),
            Text('Tamanho da fonte: ${(app.textScale * 100).round()}%'),
            Slider(
              value: app.textScale,
              min: 0.8,
              max: 1.6,
              divisions: 8,
              label: '${(app.textScale * 100).round()}%',
              semanticFormatterCallback: (v) => 'Tamanho da fonte ${(v * 100).round()} por cento',
              onChanged: app.setTextScale,
            ),
            const SectionTitle('Privacidade'),
            const Text(
              'O app não coleta dados pessoais. Ocorrências são anônimas e ficam somente neste aparelho. '
              'Você pode revogar o consentimento e apagar tudo a qualquer momento.',
            ),
            const SizedBox(height: Gap.m),
            OutlinedButton.icon(
              onPressed: _erase,
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('Revogar consentimento e apagar dados'),
            ),
          ],
        ),
      ),
    );
  }
}
