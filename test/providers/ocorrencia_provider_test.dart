import 'package:flutter_test/flutter_test.dart';
import 'package:zela_bairro/data/memory_ocorrencia_repository.dart';
import 'package:zela_bairro/models/ocorrencia.dart';
import 'package:zela_bairro/providers/ocorrencia_provider.dart';

import '../helpers.dart';

void main() {
  late MemoryOcorrenciaRepository repo;
  late OcorrenciaProvider provider;

  setUp(() {
    repo = MemoryOcorrenciaRepository(
      iniciais: [
        criarOcorrencia(
          titulo: 'Poste apagado',
          categoria: Categoria.iluminacao,
          status: StatusOcorrencia.aberta,
          prioridade: Prioridade.alta,
          criadoEm: DateTime(2026, 11, 1),
        ),
        criarOcorrencia(
          titulo: 'Lixo na praça',
          categoria: Categoria.lixo,
          status: StatusOcorrencia.resolvida,
          criadoEm: DateTime(2026, 11, 2),
        ),
        criarOcorrencia(
          titulo: 'Outro poste',
          categoria: Categoria.iluminacao,
          status: StatusOcorrencia.emAndamento,
          criadoEm: DateTime(2026, 11, 3),
        ),
      ],
    );
    provider = OcorrenciaProvider(repo);
  });

  group('OcorrenciaProvider', () {
    test('estado inicial vazio e sem carregamento', () {
      expect(provider.ocorrencias, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.erro, isNull);
    });

    test('carregar() busca os dados e alterna o estado de loading', () async {
      final estadosLoading = <bool>[];
      provider.addListener(() => estadosLoading.add(provider.isLoading));

      await provider.carregar();

      expect(estadosLoading, [true, false]);
      expect(provider.total, 3);
      // Ordenado do mais recente para o mais antigo.
      expect(provider.ocorrencias.first.titulo, 'Outro poste');
    });

    test('adicionar() insere com id e notifica a UI', () async {
      await provider.carregar();
      var notificou = false;
      provider.addListener(() => notificou = true);

      final ok = await provider.adicionar(criarOcorrencia(titulo: 'Novo'));

      expect(ok, isTrue);
      expect(notificou, isTrue);
      expect(provider.total, 4);
      expect(provider.ocorrencias.first.id, isNotNull);
      expect((await repo.listar()).length, 4);
    });

    test('atualizar() substitui o registro existente', () async {
      await provider.carregar();
      final alvo = provider.ocorrencias.first;

      await provider.atualizar(alvo.copyWith(titulo: 'Título editado'));

      expect(provider.buscarPorId(alvo.id!)!.titulo, 'Título editado');
      expect(provider.total, 3);
    });

    test('remover() exclui o registro da lista e do repositório', () async {
      await provider.carregar();
      final id = provider.ocorrencias.first.id!;

      final ok = await provider.remover(id);

      expect(ok, isTrue);
      expect(provider.buscarPorId(id), isNull);
      expect((await repo.listar()).length, 2);
    });

    test('indicadores do dashboard são calculados corretamente', () async {
      await provider.carregar();

      expect(provider.abertas, 1);
      expect(provider.emAndamento, 1);
      expect(provider.resolvidas, 1);
      expect(provider.urgentes, 1);
      expect(provider.taxaResolucao, closeTo(1 / 3, 0.001));
      expect(provider.porCategoria.keys.first, Categoria.iluminacao);
      expect(provider.porCategoria[Categoria.iluminacao], 2);
    });

    test('alterarStatus() avança o status da ocorrência', () async {
      await provider.carregar();
      final aberta = provider.ocorrencias.firstWhere(
        (o) => o.status == StatusOcorrencia.aberta,
      );

      await provider.alterarStatus(aberta.id!, StatusOcorrencia.resolvida);

      expect(provider.resolvidas, 2);
      expect(provider.abertas, 0);
    });

    test('filtro por status restringe a lista filtrada', () async {
      await provider.carregar();

      provider.filtrarPorStatus(StatusOcorrencia.resolvida);
      expect(provider.ocorrenciasFiltradas.length, 1);
      expect(provider.ocorrenciasFiltradas.single.titulo, 'Lixo na praça');

      provider.filtrarPorStatus(null);
      expect(provider.ocorrenciasFiltradas.length, 3);
    });

    test('busca ignora maiúsculas e acentos e combina com o filtro', () async {
      await provider.carregar();

      provider.buscar('PRACA');
      expect(provider.ocorrenciasFiltradas.single.titulo, 'Lixo na praça');

      provider.buscar('poste');
      expect(provider.ocorrenciasFiltradas.length, 2);

      provider.filtrarPorStatus(StatusOcorrencia.aberta);
      expect(provider.ocorrenciasFiltradas.single.titulo, 'Poste apagado');
    });

    test('listaUrgentes traz só as urgentes', () async {
      await provider.carregar();
      expect(provider.listaUrgentes.map((o) => o.titulo), ['Poste apagado']);
    });

    test('erro no repositório é exposto sem quebrar o app', () async {
      final comFalha = OcorrenciaProvider(RepositorioComFalha());

      await comFalha.carregar();
      expect(comFalha.erro, isNotNull);
      expect(comFalha.isLoading, isFalse);

      final ok = await comFalha.adicionar(criarOcorrencia());
      expect(ok, isFalse);
      expect(comFalha.total, 0);
    });
  });
}
