import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/validators.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class OccurrenceFormScreen extends StatefulWidget {
  const OccurrenceFormScreen({super.key});

  @override
  State<OccurrenceFormScreen> createState() => _OccurrenceFormScreenState();
}

class _OccurrenceFormScreenState extends State<OccurrenceFormScreen> {
  static const _categories = [
    'Vazamento de água',
    'Desperdício de água',
    'Falha de energia',
    'Calor extremo',
    'Alagamento',
    'Outro',
  ];

  // Estado local do formulário (não é compartilhado com outras telas).
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _location = TextEditingController();
  String? _category;

  @override
  void dispose() {
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final app = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    await app.addOccurrence(
      Occurrence(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        category: _category!,
        description: _description.text.trim(),
        location: _location.text.trim(),
        createdAt: DateTime.now(),
      ),
    );
    messenger.showSnackBar(const SnackBar(content: Text('Ocorrência registrada de forma anônima.')));
    router.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova ocorrência')),
      body: ResponsiveBody(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(Gap.m),
            children: [
              const NoticeBanner(
                icon: Icons.privacy_tip_outlined,
                text: 'Registro anônimo. Não informe nome, telefone, e-mail ou documentos.',
              ),
              const SizedBox(height: Gap.m),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: fieldDecoration('Categoria'),
                items: [for (final c in _categories) DropdownMenuItem(value: c, child: Text(c))],
                onChanged: (v) => setState(() => _category = v),
                validator: Validators.category,
              ),
              const SizedBox(height: Gap.m),
              TextFormField(
                controller: _location,
                decoration: fieldDecoration('Local', hint: 'Ex.: Praça central, Rua das Flores'),
                textInputAction: TextInputAction.next,
                validator: Validators.location,
              ),
              const SizedBox(height: Gap.m),
              TextFormField(
                controller: _description,
                decoration: fieldDecoration('Descrição', helper: 'De 10 a 280 caracteres.'),
                minLines: 3,
                maxLines: 5,
                maxLength: 280,
                validator: Validators.description,
              ),
              const SizedBox(height: Gap.m),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Registrar ocorrência'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
