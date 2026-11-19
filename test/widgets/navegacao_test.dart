import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zela_bairro/core/routes/app_routes.dart';
import 'package:zela_bairro/data/memory_ocorrencia_repository.dart';
import 'package:zela_bairro/models/ocorrencia.dart';
import 'package:zela_bairro/providers/ocorrencia_provider.dart';

import '../helpers.dart';

void main() {
  testWidgets('Barra inferior troca de aba e painel abre a lista filtrada', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final provider = OcorrenciaProvider(
      MemoryOcorrenciaRepository(
        iniciais: [
          criarOcorrencia(titulo: 'Poste apagado'),
          criarOcorrencia(
            titulo: 'Lixo na praça',
            status: StatusOcorrencia.resolvida,
          ),
        ],
      ),
    );
    await provider.carregar();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(onGenerateRoute: AppRoutes.onGenerateRoute),
      ),
    );
    await tester.pumpAndSettle();

    // Aba Sobre
    await tester.tap(find.text('Sobre'));
    await tester.pumpAndSettle();
    expect(find.text('Sobre o ZelaBairro'), findsOneWidget);

    // Volta ao Início e toca em "Resolvida" no painel
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Resolvida: 1'));
    await tester.pumpAndSettle();

    expect(provider.filtroStatus, StatusOcorrencia.resolvida);
    expect(find.text('Lixo na praça'), findsOneWidget);
    expect(find.text('Poste apagado'), findsNothing);
  });
}
