import 'package:flutter_test/flutter_test.dart';
import 'package:zela_bairro/utils/formatters.dart';
import 'package:zela_bairro/utils/validators.dart';

void main() {
  group('Validators', () {
    test('título vazio ou só espaços é inválido', () {
      expect(Validators.titulo(null), 'Título é obrigatório');
      expect(Validators.titulo('   '), 'Título é obrigatório');
    });

    test('título precisa ter entre 5 e 60 caracteres', () {
      expect(Validators.titulo('Abc'), contains('pelo menos 5'));
      expect(Validators.titulo('A' * 61), contains('no máximo 60'));
      expect(Validators.titulo('Poste apagado'), isNull);
    });

    test('descrição exige no mínimo 15 caracteres', () {
      expect(Validators.descricao(''), 'Descrição é obrigatória');
      expect(Validators.descricao('curto demais'), isNotNull);
      expect(Validators.descricao('Bueiro entupido há uma semana'), isNull);
    });

    test('endereço precisa conter letras', () {
      expect(Validators.endereco('12345'), isNotNull);
      expect(Validators.endereco('Rua das Flores, 10'), isNull);
    });

    test('bairro obrigatório com pelo menos 3 letras', () {
      expect(Validators.bairro(''), isNotNull);
      expect(Validators.bairro('AB'), 'Bairro inválido');
      expect(Validators.bairro('Centro'), isNull);
    });

    test('checkbox de confirmação precisa estar marcado', () {
      expect(Validators.confirmacao(false), isNotNull);
      expect(Validators.confirmacao(null), isNotNull);
      expect(Validators.confirmacao(true), isNull);
    });
  });

  group('Formatters', () {
    test('dataHora usa o formato brasileiro', () {
      expect(
        Formatters.dataHora(DateTime(2026, 11, 19, 8, 5)),
        '19/11/2026 08:05',
      );
    });

    test('percentual arredonda para inteiro', () {
      expect(Formatters.percentual(0), '0%');
      expect(Formatters.percentual(0.666), '67%');
      expect(Formatters.percentual(1), '100%');
    });
  });
}
