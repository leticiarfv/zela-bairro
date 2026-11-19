import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zela_bairro/data/database_helper.dart';
import 'package:zela_bairro/data/seed_data.dart';
import 'package:zela_bairro/data/sqlite_ocorrencia_repository.dart';
import 'package:zela_bairro/models/ocorrencia.dart';

import '../helpers.dart';

/// Testa a camada SQLite real usando um banco em memória (sqflite_ffi).
void main() {
  late DatabaseHelper helper;
  late SqliteOcorrenciaRepository repo;

  setUpAll(sqfliteFfiInit);

  Future<void> abrir({bool seed = true}) async {
    helper = DatabaseHelper(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
      seed: seed,
    );
    repo = SqliteOcorrenciaRepository(helper);
  }

  tearDown(() => helper.close());

  group('SqliteOcorrenciaRepository', () {
    test('onCreate cria a tabela e grava a carga inicial (seed)', () async {
      await abrir();
      final lista = await repo.listar();
      expect(lista.length, seedOcorrencias().length);
    });

    test('inserir() gera id e permite ler o registro de volta', () async {
      await abrir(seed: false);

      final salva = await repo.inserir(criarOcorrencia(titulo: 'Bueiro'));
      final lista = await repo.listar();

      expect(salva.id, isNotNull);
      expect(lista.single.titulo, 'Bueiro');
      expect(lista.single.id, salva.id);
    });

    test('atualizar() persiste as alterações', () async {
      await abrir(seed: false);
      final salva = await repo.inserir(criarOcorrencia());

      await repo.atualizar(
        salva.copyWith(
          status: StatusOcorrencia.resolvida,
          riscoSeguranca: true,
        ),
      );

      final lida = (await repo.listar()).single;
      expect(lida.status, StatusOcorrencia.resolvida);
      expect(lida.riscoSeguranca, isTrue);
    });

    test('excluir() remove o registro', () async {
      await abrir(seed: false);
      final a = await repo.inserir(criarOcorrencia(titulo: 'A'));
      await repo.inserir(criarOcorrencia(titulo: 'B'));

      await repo.excluir(a.id!);

      final lista = await repo.listar();
      expect(lista.length, 1);
      expect(lista.single.titulo, 'B');
    });

    test('atualizar() sem id lança erro', () async {
      await abrir(seed: false);
      expect(() => repo.atualizar(criarOcorrencia()), throwsArgumentError);
    });
  });
}
