import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../models/ocorrencia.dart';
import '../providers/ocorrencia_provider.dart';
import 'home_screen.dart';
import 'lista_screen.dart';
import 'sobre_screen.dart';

/// Estrutura principal: barra de navegação inferior com 3 abas
/// (Início, Ocorrências, Sobre) e o botão "Reportar" sempre à mão.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, this.abaInicial = 0});

  final int abaInicial;

  static const int abaInicio = 0;
  static const int abaOcorrencias = 1;
  static const int abaSobre = 2;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  late int _aba = widget.abaInicial;

  void _irPara(int aba) => setState(() => _aba = aba);

  /// Chamado pelo painel da Home: aplica o filtro e abre a aba da lista.
  void _verLista(StatusOcorrencia? filtro) {
    context.read<OcorrenciaProvider>().filtrarPorStatus(filtro);
    _irPara(ShellScreen.abaOcorrencias);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Voltar em outra aba retorna ao Início antes de sair do app.
      canPop: _aba == ShellScreen.abaInicio,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _irPara(ShellScreen.abaInicio);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _aba,
          children: [
            HomeScreen(onVerLista: _verLista),
            const ListaScreen(),
            const SobreScreen(),
          ],
        ),
        floatingActionButton: _aba == ShellScreen.abaSobre
            ? null
            : FloatingActionButton.extended(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.formulario),
                icon: const Icon(Icons.add),
                label: const Text('Reportar'),
              ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: NavigationBar(
            selectedIndex: _aba,
            onDestinationSelected: _irPara,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard),
                label: 'Início',
              ),
              NavigationDestination(
                icon: Icon(Icons.view_agenda_outlined),
                selectedIcon: Icon(Icons.view_agenda),
                label: 'Ocorrências',
              ),
              NavigationDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: 'Sobre',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
