import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ResponsiveBody(
          child: ListView(
            padding: const EdgeInsets.all(Gap.l),
            children: [
              Icon(Icons.insights_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: Gap.m),
              Semantics(
                header: true,
                child: Text('Território Preditivo', style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: Gap.s),
              const Text('Painel de inteligência territorial para antecipar desperdício de recursos e eventos climáticos no seu bairro.'),
              const SizedBox(height: Gap.l),
              const SectionTitle('Seus dados e sua privacidade'),
              const AppCard(
                child: IconBulletList(
                  icon: Icons.verified_user_outlined,
                  items: [
                    'O app não pede nome, telefone, e-mail nem localização exata.',
                    'Ocorrências que você registrar são anônimas e ficam apenas neste aparelho.',
                    'Os alertas são estimativas com limitações: apoiam, mas não substituem, a decisão humana.',
                    'Você pode revogar o consentimento e apagar tudo a qualquer momento em Ajustes.',
                  ],
                ),
              ),
              const SizedBox(height: Gap.l),
              CheckboxListTile(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text('Li e concordo com o uso anônimo e local dos meus dados.'),
              ),
              const SizedBox(height: Gap.m),
              FilledButton(
                onPressed: _agreed ? () => context.read<AppState>().setConsent(true) : null,
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
