import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../models/ocorrencia.dart';

/// Pílula de status. A cor reforça, mas o texto sempre diz o status.
class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});

  final StatusOcorrencia status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontFamily: AppTheme.fonteTexto,
          color: status.fg,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Prioridade como intensidade: 1, 2 ou 3 marcas preenchidas + rótulo.
class PrioridadeMeter extends StatelessWidget {
  const PrioridadeMeter(this.prioridade, {super.key});

  final Prioridade prioridade;

  @override
  Widget build(BuildContext context) {
    final cor = prioridade.cor;
    return Semantics(
      label: 'Prioridade ${prioridade.label}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 3; i++) ...[
            Container(
              width: 6,
              height: 6 + i * 4,
              decoration: BoxDecoration(
                color: i <= prioridade.nivel ? cor : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (i < 3) const SizedBox(width: 2),
          ],
          const SizedBox(width: 8),
          Text(
            'Prioridade ${prioridade.label}',
            style: TextStyle(
              fontFamily: AppTheme.fonteTexto,
              color: cor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso de risco à segurança (dado real da ocorrência).
class RiscoPill extends StatelessWidget {
  const RiscoPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Risco à segurança',
        style: TextStyle(
          fontFamily: AppTheme.fonteTexto,
          color: AppColors.danger,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
