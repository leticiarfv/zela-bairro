import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../models/ocorrencia.dart';
import '../providers/ocorrencia_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/feedback_states.dart';
import '../widgets/ocorrencia_card.dart';

/// Tela 2: listagem dinâmica com ListView.separated, busca, filtros e
/// estados de loading, lista vazia e erro.
class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  final _buscaCtrl = TextEditingController();

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  void _limparBusca() {
    _buscaCtrl.clear();
    context.read<OcorrenciaProvider>().buscar('');
    setState(() {});
  }

  Future<void> _onAcao(Ocorrencia o, AcaoCard acao) async {
    switch (acao) {
      case AcaoCard.editar:
        await Navigator.pushNamed(context, AppRoutes.formulario, arguments: o);
      case AcaoCard.excluir:
        final ok = await mostrarConfirmacao(
          context,
          titulo: 'Excluir ocorrência?',
          mensagem: 'Isso apaga "${o.titulo}". Não dá para desfazer.',
        );
        if (!ok || !mounted) return;
        final sucesso = await context.read<OcorrenciaProvider>().remover(o.id!);
        if (!mounted) return;
        mostrarSnack(
          context,
          sucesso ? 'Ocorrência excluída' : 'Erro ao excluir ocorrência',
          erro: !sucesso,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ocorrências')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _buscaCtrl,
              textInputAction: TextInputAction.search,
              onChanged: (v) {
                context.read<OcorrenciaProvider>().buscar(v);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Buscar por título ou bairro',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscaCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.close),
                        onPressed: _limparBusca,
                      ),
              ),
            ),
          ),
          const _FiltroStatus(),
          Expanded(
            child: Consumer<OcorrenciaProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.ocorrencias.isEmpty) {
                  return const LoadingState(
                    mensagem: 'Carregando ocorrências...',
                  );
                }

                if (provider.erro != null && provider.ocorrencias.isEmpty) {
                  return ErrorState(
                    mensagem: provider.erro!,
                    onRetry: provider.carregar,
                  );
                }

                final itens = provider.ocorrenciasFiltradas;
                if (itens.isEmpty) {
                  if (provider.busca.trim().isNotEmpty) {
                    return const EmptyState(
                      titulo: 'Nenhuma ocorrência encontrada',
                      mensagem: 'Tente outro termo ou limpe a busca.',
                    );
                  }
                  final filtrando = provider.filtroStatus != null;
                  return EmptyState(
                    titulo: filtrando
                        ? 'Nenhuma ocorrência com status '
                              '"${provider.filtroStatus!.label}"'
                        : 'Nenhuma ocorrência registrada',
                    mensagem: filtrando
                        ? null
                        : 'Toque em Reportar para registrar um problema.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: provider.carregar,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    itemCount: itens.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final o = itens[index];
                      return OcorrenciaCard(
                        key: ValueKey(o.id),
                        ocorrencia: o,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.detalhes,
                          arguments: o.id,
                        ),
                        onAcao: (acao) => _onAcao(o, acao),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltroStatus extends StatelessWidget {
  const _FiltroStatus();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OcorrenciaProvider>();
    final atual = provider.filtroStatus;

    Widget chip(String label, StatusOcorrencia? valor, int qtd) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(
            '$label ($qtd)',
            style: TextStyle(
              color: atual == valor ? Colors.white : AppColors.ink,
            ),
          ),
          selected: atual == valor,
          selectedColor: AppColors.ink,
          backgroundColor: AppColors.surface,
          onSelected: (_) =>
              context.read<OcorrenciaProvider>().filtrarPorStatus(valor),
        ),
      );
    }

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
        children: [
          chip('Todas', null, provider.total),
          for (final s in StatusOcorrencia.values)
            chip(s.label, s, provider.contarPorStatus(s)),
        ],
      ),
    );
  }
}
