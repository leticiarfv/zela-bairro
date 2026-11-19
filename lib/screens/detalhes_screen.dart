import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../models/ocorrencia.dart';
import '../providers/ocorrencia_provider.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/feedback_states.dart';
import '../widgets/indicadores.dart';

/// Tela 4: detalhes de uma ocorrência. Recebe o id via argumento de rota
/// e lê o registro do Provider, então reflete edições automaticamente.
class DetalhesScreen extends StatelessWidget {
  const DetalhesScreen({super.key, required this.ocorrenciaId});

  final int ocorrenciaId;

  Future<void> _excluir(BuildContext context, Ocorrencia o) async {
    final ok = await mostrarConfirmacao(
      context,
      titulo: 'Excluir ocorrência?',
      mensagem: 'Isso apaga "${o.titulo}". Não dá para desfazer.',
    );
    if (!ok || !context.mounted) return;
    final sucesso = await context.read<OcorrenciaProvider>().remover(o.id!);
    if (!context.mounted) return;
    if (sucesso) {
      mostrarSnack(context, 'Ocorrência excluída');
      Navigator.pop(context);
    } else {
      mostrarSnack(context, 'Erro ao excluir ocorrência', erro: true);
    }
  }

  Future<void> _avancarStatus(BuildContext context, Ocorrencia o) async {
    final proximo = o.status == StatusOcorrencia.aberta
        ? StatusOcorrencia.emAndamento
        : StatusOcorrencia.resolvida;
    final sucesso = await context.read<OcorrenciaProvider>().alterarStatus(
      o.id!,
      proximo,
    );
    if (!context.mounted) return;
    mostrarSnack(
      context,
      sucesso ? 'Status alterado para "${proximo.label}"' : 'Erro ao alterar',
      erro: !sucesso,
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = context.select<OcorrenciaProvider, Ocorrencia?>(
      (p) => p.buscarPorId(ocorrenciaId),
    );

    if (o == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes')),
        body: const EmptyState(titulo: 'Ocorrência não encontrada'),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da ocorrência')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            o.categoria.label,
            style: theme.textTheme.labelLarge?.copyWith(color: AppColors.brand),
          ),
          const SizedBox(height: 8),
          Text(o.titulo, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PrioridadeMeter(o.prioridade),
              if (o.riscoSeguranca) const RiscoPill(),
            ],
          ),
          const SizedBox(height: 24),
          _LinhaDoTempo(status: o.status),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Descrição', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(o.descricao, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _InfoLinha(titulo: 'Endereço', valor: o.endereco),
                const Divider(indent: 16, endIndent: 16),
                _InfoLinha(titulo: 'Bairro', valor: o.bairro),
                const Divider(indent: 16, endIndent: 16),
                _InfoLinha(
                  titulo: 'Reportada em',
                  valor: Formatters.dataHora(o.criadoEm),
                ),
                const Divider(indent: 16, endIndent: 16),
                _InfoLinha(
                  titulo: 'Protocolo',
                  valor: '#${o.id.toString().padLeft(5, '0')}',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BarraAcoes(
        ocorrencia: o,
        onAvancar: () => _avancarStatus(context, o),
        onEditar: () =>
            Navigator.pushNamed(context, AppRoutes.formulario, arguments: o),
        onExcluir: () => _excluir(context, o),
      ),
    );
  }
}

/// Progresso Aberta → Em andamento → Resolvida.
class _LinhaDoTempo extends StatelessWidget {
  const _LinhaDoTempo({required this.status});

  final StatusOcorrencia status;

  @override
  Widget build(BuildContext context) {
    final etapas = StatusOcorrencia.values;
    final atual = status.index;

    return Semantics(
      label: 'Status: ${status.label}',
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < etapas.length; i++) ...[
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 2,
                              color: i == 0
                                  ? Colors.transparent
                                  : (i <= atual
                                        ? AppColors.ink
                                        : AppColors.border),
                            ),
                          ),
                          _Marco(
                            concluido: i < atual,
                            atual: i == atual,
                            cor: etapas[i].fg,
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: i == etapas.length - 1
                                  ? Colors.transparent
                                  : (i < atual
                                        ? AppColors.ink
                                        : AppColors.border),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        etapas[i].label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: i == atual
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: i <= atual
                              ? AppColors.ink
                              : AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Marco extends StatelessWidget {
  const _Marco({
    required this.concluido,
    required this.atual,
    required this.cor,
  });

  final bool concluido;
  final bool atual;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    if (concluido) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.ink,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: atual ? cor : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: atual ? cor : AppColors.borderStrong,
          width: 2,
        ),
      ),
    );
  }
}

class _InfoLinha extends StatelessWidget {
  const _InfoLinha({required this.titulo, required this.valor});

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(titulo, style: theme.textTheme.bodySmall),
          ),
          Expanded(child: Text(valor, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// Ações fixas no rodapé, acima da área segura.
class _BarraAcoes extends StatelessWidget {
  const _BarraAcoes({
    required this.ocorrencia,
    required this.onAvancar,
    required this.onEditar,
    required this.onExcluir,
  });

  final Ocorrencia ocorrencia;
  final VoidCallback onAvancar;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!ocorrencia.resolvida) ...[
                FilledButton(
                  onPressed: onAvancar,
                  child: Text(
                    ocorrencia.status == StatusOcorrencia.aberta
                        ? 'Marcar como em andamento'
                        : 'Marcar como resolvida',
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onEditar,
                      child: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                      ),
                      onPressed: onExcluir,
                      child: const Text('Excluir'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
