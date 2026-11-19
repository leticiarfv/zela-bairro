import 'package:flutter/material.dart';

import '../models/ocorrencia.dart';
import 'indicadores.dart';

enum AcaoCard { editar, excluir }

/// Item da listagem de ocorrências.
class OcorrenciaCard extends StatelessWidget {
  const OcorrenciaCard({
    super.key,
    required this.ocorrencia,
    required this.onTap,
    required this.onAcao,
  });

  final Ocorrencia ocorrencia;
  final VoidCallback onTap;
  final ValueChanged<AcaoCard> onAcao;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final o = ocorrencia;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusPill(o.status),
                  const Spacer(),
                  PopupMenuButton<AcaoCard>(
                    tooltip: 'Ações',
                    onSelected: onAcao,
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: AcaoCard.editar,
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Editar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: AcaoCard.excluir,
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Excluir'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      o.bairro,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    PrioridadeMeter(o.prioridade),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
