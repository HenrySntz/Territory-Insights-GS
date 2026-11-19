import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';

class OccurrencesScreen extends StatelessWidget {
  const OccurrencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final fmtDate = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Ocorrências cidadãs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('occurrence-new'),
        icon: const Icon(Icons.add),
        label: const Text('Nova ocorrência'),
      ),
      body: app.occurrences.isEmpty
          ? const StateView.empty(
              message: 'Nenhuma ocorrência registrada.\nToque em "Nova ocorrência" para relatar um problema no território.',
              icon: Icons.edit_note,
            )
          : ResponsiveBody(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Gap.m, Gap.m, Gap.m, 96),
                children: [
                  for (final o in app.occurrences) ...[
                    AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InfoPill(text: o.category, icon: Icons.label_outline_rounded),
                                const SizedBox(height: 8),
                                Text('${o.location} · ${fmtDate.format(o.createdAt)}', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 4),
                                Text(o.description),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Excluir ocorrência',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => app.removeOccurrence(o.id),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Gap.s),
                  ],
                ],
              ),
            ),
    );
  }
}
