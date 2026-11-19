import 'package:flutter/material.dart';

import '../core/constants/ods.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Selo de ODS: amostra da cor oficial da ONU + texto escuro.
/// O texto nunca fica sobre a cor oficial, para manter o contraste.
class OdsChip extends StatelessWidget {
  const OdsChip({super.key, required this.ods});

  final Ods ods;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ODS ${ods.numero}: ${ods.titulo}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: ods.cor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ODS ${ods.numero}',
              style: const TextStyle(
                fontFamily: AppTheme.fonteTexto,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
