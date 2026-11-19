import 'package:flutter/material.dart';

/// Estado de carregamento padronizado.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.mensagem = 'Carregando...'});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(mensagem),
        ],
      ),
    );
  }
}

/// Mensagem quando não há itens para exibir.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.titulo,
    this.mensagem,
    this.acaoLabel,
    this.onAcao,
  });

  final String titulo;
  final String? mensagem;
  final String? acaoLabel;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titulo,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (mensagem != null) ...[
              const SizedBox(height: 8),
              Text(
                mensagem!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            if (acaoLabel != null && onAcao != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: onAcao, child: Text(acaoLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de erro com botão de nova tentativa.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.mensagem, required this.onRetry});

  final String mensagem;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
