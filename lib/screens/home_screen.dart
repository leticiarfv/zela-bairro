import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/ods.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../models/ocorrencia.dart';
import '../providers/ocorrencia_provider.dart';
import '../utils/formatters.dart';
import '../widgets/indicadores.dart';
import '../widgets/ods_chip.dart';
import '../widgets/section_title.dart';

/// Tela 1: Dashboard CitizenTech com indicadores consumidos via Provider.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onVerLista});

  /// Abre a lista já filtrada (null = todas). Vem do [ShellScreen].
  final void Function(StatusOcorrencia? filtro)? onVerLista;

  void _verLista(BuildContext context, [StatusOcorrencia? filtro]) {
    if (onVerLista != null) {
      onVerLista!(filtro);
    } else {
      context.read<OcorrenciaProvider>().filtrarPorStatus(filtro);
      Navigator.pushNamed(context, AppRoutes.lista);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OcorrenciaProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: provider.carregar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              Row(
                children: [
                  Text(
                    'ZelaBairro',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.brand,
                    ),
                  ),
                  const Spacer(),
                  if (provider.isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Reporte problemas do seu bairro e acompanhe até a solução.',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text('ODS da ONU atendidos', style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final ods in odsAtendidos) OdsChip(ods: ods)],
              ),
              const SizedBox(height: 24),
              _PainelStatus(
                provider: provider,
                onTapStatus: (s) => _verLista(context, s),
              ),
              const SizedBox(height: 32),
              SectionTitle(
                'Urgentes',
                trailing: TextButton(
                  onPressed: () => _verLista(context),
                  child: const Text('Ver todas'),
                ),
              ),
              _ListaUrgentes(ocorrencias: provider.listaUrgentes),
              if (provider.porCategoria.isNotEmpty) ...[
                const SizedBox(height: 32),
                const SectionTitle('Problemas por categoria'),
                _CardCategorias(porCategoria: provider.porCategoria),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Painel escuro com o total, a distribuição por status (barra empilhada)
/// e a taxa de resolução. Cada linha de status abre a lista filtrada.
class _PainelStatus extends StatelessWidget {
  const _PainelStatus({required this.provider, required this.onTapStatus});

  final OcorrenciaProvider provider;
  final ValueChanged<StatusOcorrencia?> onTapStatus;

  @override
  Widget build(BuildContext context) {
    final total = provider.total;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Panorama do bairro',
            style: TextStyle(color: AppColors.onDarkMuted, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Semantics(
            button: true,
            label: 'Total reportado: $total. Ver todas',
            excludeSemantics: true,
            child: InkWell(
              onTap: () => onTapStatus(null),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontFamily: AppTheme.fonteTitulo,
                      fontWeight: FontWeight.w600,
                      fontSize: 56,
                      height: 1,
                      color: AppColors.onDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Total reportado',
                      style: TextStyle(color: AppColors.onDark, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _BarraEmpilhada(provider: provider),
          const SizedBox(height: 12),
          for (final s in StatusOcorrencia.values)
            _LinhaStatus(
              status: s,
              quantidade: provider.contarPorStatus(s),
              onTap: () => onTapStatus(s),
            ),
          const Divider(color: AppColors.onDarkDivider, height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Taxa de resolução',
                  style: TextStyle(color: AppColors.onDarkMuted, fontSize: 15),
                ),
              ),
              Text(
                Formatters.percentual(provider.taxaResolucao),
                style: const TextStyle(
                  fontFamily: AppTheme.fonteTitulo,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  color: AppColors.onDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _BarraEmpilhada extends StatelessWidget {
  const _BarraEmpilhada({required this.provider});

  final OcorrenciaProvider provider;

  @override
  Widget build(BuildContext context) {
    final partes = [
      for (final s in StatusOcorrencia.values)
        if (provider.contarPorStatus(s) > 0) s,
    ];

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 12,
          width: double.infinity,
          child: partes.isEmpty
              ? const ColoredBox(color: AppColors.onDarkDivider)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < partes.length; i++) ...[
                      if (i > 0) const SizedBox(width: 3),
                      Expanded(
                        flex: provider.contarPorStatus(partes[i]),
                        child: ColoredBox(color: partes[i].onDark),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _LinhaStatus extends StatelessWidget {
  const _LinhaStatus({
    required this.status,
    required this.quantidade,
    required this.onTap,
  });

  final StatusOcorrencia status;
  final int quantidade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${status.label}: $quantidade',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: status.onDark,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status.label,
                  style: const TextStyle(color: AppColors.onDark, fontSize: 15),
                ),
              ),
              Text(
                '$quantidade',
                style: const TextStyle(
                  fontFamily: AppTheme.fonteTitulo,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.onDark,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.onDarkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListaUrgentes extends StatelessWidget {
  const _ListaUrgentes({required this.ocorrencias});

  final List<Ocorrencia> ocorrencias;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (ocorrencias.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Nenhuma ocorrência urgente em aberto.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.inkMuted,
            ),
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < ocorrencias.length; i++) ...[
            if (i > 0) const Divider(indent: 16, endIndent: 16),
            InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.detalhes,
                arguments: ocorrencias[i].id,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ocorrencias[i].titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ocorrencias[i].bairro,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          PrioridadeMeter(ocorrencias[i].prioridade),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.inkMuted),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardCategorias extends StatelessWidget {
  const _CardCategorias({required this.porCategoria});

  final Map<Categoria, int> porCategoria;

  @override
  Widget build(BuildContext context) {
    final entradas = porCategoria.entries.toList();
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < entradas.length; i++) ...[
            if (i > 0) const Divider(indent: 16, endIndent: 16),
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entradas[i].key.label,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${entradas[i].value}',
                      style: const TextStyle(
                        fontFamily: AppTheme.fonteTitulo,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
