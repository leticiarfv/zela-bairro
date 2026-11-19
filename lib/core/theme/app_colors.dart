import 'package:flutter/material.dart';

import '../../models/ocorrencia.dart';

/// Tokens de cor do ZelaBairro.
///
/// Cada cor tem um único papel, para nada colidir:
/// - [brand] (cobalto): ações e navegação.
/// - Status: ardósia = aberta, âmbar = em andamento, verde = resolvida.
/// - [danger] (vermelho): prioridade alta, risco e exclusão.
/// - Cores oficiais dos ODS aparecem só como amostras ao lado de texto
///   escuro (o laranja do ODS 11 com texto branco reprova no contraste).
///
/// Contraste de texto verificado (WCAG): todos os pares acima de 4.5:1.
class AppColors {
  const AppColors._();

  // Superfícies
  static const Color bg = Color(0xFFF3F1EC); // concreto
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEBE8E1);
  static const Color border = Color(0xFFDEDAD1);
  static const Color borderStrong = Color(0xFFBDB8AD);

  // Texto
  static const Color ink = Color(0xFF191D1B); // 15:1 sobre bg
  static const Color inkMuted = Color(0xFF565D59); // 6:1 sobre bg

  // Superfície escura (painel)
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkMuted = Color(0xFFA9B0AB); // 7.7:1 sobre ink
  static const Color onDarkDivider = Color(0x29FFFFFF);

  // Ação
  static const Color brand = Color(0xFF2E3BC9); // 8.1:1 sobre branco
  static const Color brandSoft = Color(0xFFE4E6FA);

  // Perigo
  static const Color danger = Color(0xFFB42318);
  static const Color dangerSoft = Color(0xFFFDE8E6);
}

/// Cores de cada status em fundo claro (pílula) e no painel escuro (barra).
extension StatusVisual on StatusOcorrencia {
  Color get fg => switch (this) {
    StatusOcorrencia.aberta => const Color(0xFF334155),
    StatusOcorrencia.emAndamento => const Color(0xFF92400E),
    StatusOcorrencia.resolvida => const Color(0xFF166534),
  };

  Color get bg => switch (this) {
    StatusOcorrencia.aberta => const Color(0xFFE2E8F0),
    StatusOcorrencia.emAndamento => const Color(0xFFFEF0C7),
    StatusOcorrencia.resolvida => const Color(0xFFDCF5E3),
  };

  Color get onDark => switch (this) {
    StatusOcorrencia.aberta => const Color(0xFF94A3B8),
    StatusOcorrencia.emAndamento => const Color(0xFFF5A524),
    StatusOcorrencia.resolvida => const Color(0xFF34C072),
  };
}

/// Prioridade usa intensidade (1 a 3 marcas), não matiz. Só "alta" é vermelha.
extension PrioridadeVisual on Prioridade {
  int get nivel => index + 1;

  Color get cor => this == Prioridade.alta ? AppColors.danger : AppColors.ink;
}
