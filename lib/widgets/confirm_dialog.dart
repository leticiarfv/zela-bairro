import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Diálogo de confirmação reutilizável. Retorna `true` se confirmado.
Future<bool> mostrarConfirmacao(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String confirmar = 'Excluir',
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.ink),
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            minimumSize: const Size(0, 48),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmar),
        ),
      ],
    ),
  );
  return resultado ?? false;
}

/// Sucesso usa a cor neutra (tinta) para não colidir com o verde de
/// "Resolvida". Erro usa vermelho.
void mostrarSnack(BuildContext context, String mensagem, {bool erro = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? AppColors.danger : AppColors.ink,
      ),
    );
}
