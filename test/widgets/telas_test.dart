import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zela_bairro/data/memory_ocorrencia_repository.dart';
import 'package:zela_bairro/models/ocorrencia.dart';
import 'package:zela_bairro/providers/ocorrencia_provider.dart';
import 'package:zela_bairro/screens/formulario_screen.dart';
import 'package:zela_bairro/screens/lista_screen.dart';

Widget _app(OcorrenciaProvider provider, Widget tela) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(home: tela),
  );
}

void main() {
  testWidgets('Lista vazia mostra mensagem amigável', (tester) async {
    final provider = OcorrenciaProvider(MemoryOcorrenciaRepository());
    await provider.carregar();

    await tester.pumpWidget(_app(provider, const ListaScreen()));

    expect(find.text('Nenhuma ocorrência registrada'), findsOneWidget);
    expect(find.byType(ListView), findsWidgets);
  });

  testWidgets('Formulário bloqueia envio com campos vazios', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final provider = OcorrenciaProvider(MemoryOcorrenciaRepository());
    await tester.pumpWidget(_app(provider, const FormularioScreen()));

    await tester.tap(find.byKey(const Key('botao_salvar')));
    await tester.pumpAndSettle();

    expect(find.text('Título é obrigatório'), findsOneWidget);
    expect(find.text('Selecione uma categoria'), findsOneWidget);
    expect(provider.total, 0);
  });

  testWidgets('Formulário válido salva a ocorrência via Provider', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final provider = OcorrenciaProvider(MemoryOcorrenciaRepository());
    await tester.pumpWidget(_app(provider, const FormularioScreen()));

    await tester.enterText(
      find.byKey(const Key('campo_titulo')),
      'Árvore caída na calçada',
    );
    await tester.enterText(
      find.byKey(const Key('campo_descricao')),
      'Árvore bloqueando a passagem de pedestres.',
    );
    await tester.enterText(
      find.byKey(const Key('campo_endereco')),
      'Rua Augusta, 500',
    );
    await tester.enterText(find.byKey(const Key('campo_bairro')), 'Consolação');

    await tester.tap(find.byKey(const Key('campo_categoria')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Categoria.outros.label).last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('campo_confirmacao')));
    await tester.tap(find.byKey(const Key('botao_salvar')));
    await tester.pumpAndSettle();

    expect(provider.total, 1);
    expect(provider.ocorrencias.single.bairro, 'Consolação');
    expect(provider.ocorrencias.single.categoria, Categoria.outros);
  });
}
