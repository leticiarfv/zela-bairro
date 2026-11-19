import 'package:flutter_test/flutter_test.dart';
import 'package:zela_bairro/models/ocorrencia.dart';

import '../helpers.dart';

void main() {
  group('Ocorrencia (model)', () {
    test('toMap e fromMap preservam todos os dados', () {
      final original = criarOcorrencia(
        id: 7,
        prioridade: Prioridade.alta,
        status: StatusOcorrencia.emAndamento,
        risco: true,
      );

      final copia = Ocorrencia.fromMap(original.toMap());

      expect(copia, equals(original));
      expect(original.toMap()['risco_seguranca'], 1);
      expect(original.toMap()['categoria'], 'buraco');
    });

    test('toMap não envia id quando o registro ainda é novo', () {
      final nova = criarOcorrencia();
      expect(nova.toMap().containsKey('id'), isFalse);
    });

    test('copyWith altera apenas os campos informados', () {
      final o = criarOcorrencia(id: 1);
      final editada = o.copyWith(status: StatusOcorrencia.resolvida);

      expect(editada.status, StatusOcorrencia.resolvida);
      expect(editada.id, o.id);
      expect(editada.titulo, o.titulo);
      expect(editada.resolvida, isTrue);
    });

    test('fromMap usa valores padrão para enums desconhecidos', () {
      final o = Ocorrencia.fromMap({
        'id': 1,
        'titulo': 'X',
        'categoria': 'inexistente',
        'prioridade': '???',
        'status': null,
        'criado_em': '2026-01-01T00:00:00.000',
      });

      expect(o.categoria, Categoria.outros);
      expect(o.prioridade, Prioridade.media);
      expect(o.status, StatusOcorrencia.aberta);
      expect(o.riscoSeguranca, isFalse);
    });

    test('regra "urgente": prioridade alta ou risco, se não resolvida', () {
      expect(criarOcorrencia(prioridade: Prioridade.alta).urgente, isTrue);
      expect(criarOcorrencia(risco: true).urgente, isTrue);
      expect(criarOcorrencia(prioridade: Prioridade.baixa).urgente, isFalse);
      expect(
        criarOcorrencia(
          prioridade: Prioridade.alta,
          status: StatusOcorrencia.resolvida,
        ).urgente,
        isFalse,
      );
    });
  });
}
