import 'package:zela_bairro/data/ocorrencia_repository.dart';
import 'package:zela_bairro/models/ocorrencia.dart';

Ocorrencia criarOcorrencia({
  int? id,
  String titulo = 'Buraco na rua principal',
  Categoria categoria = Categoria.buraco,
  Prioridade prioridade = Prioridade.media,
  StatusOcorrencia status = StatusOcorrencia.aberta,
  bool risco = false,
  DateTime? criadoEm,
}) {
  return Ocorrencia(
    id: id,
    titulo: titulo,
    descricao: 'Descrição detalhada do problema reportado.',
    categoria: categoria,
    endereco: 'Rua Teste, 123',
    bairro: 'Centro',
    prioridade: prioridade,
    status: status,
    riscoSeguranca: risco,
    criadoEm: criadoEm ?? DateTime(2026, 11, 10, 9, 30),
  );
}

/// Repositório que sempre falha, para testar o tratamento de erros.
class RepositorioComFalha implements OcorrenciaRepository {
  @override
  Future<List<Ocorrencia>> listar() async => throw Exception('offline');

  @override
  Future<Ocorrencia> inserir(Ocorrencia o) async => throw Exception('falha');

  @override
  Future<void> atualizar(Ocorrencia o) async => throw Exception('falha');

  @override
  Future<void> excluir(int id) async => throw Exception('falha');
}
