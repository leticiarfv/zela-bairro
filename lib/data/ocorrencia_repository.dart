import '../models/ocorrencia.dart';

/// Contrato da camada de dados. A UI e o Provider dependem apenas
/// desta abstração, nunca da implementação concreta (SQLite / memória).
abstract class OcorrenciaRepository {
  Future<List<Ocorrencia>> listar();
  Future<Ocorrencia> inserir(Ocorrencia ocorrencia);
  Future<void> atualizar(Ocorrencia ocorrencia);
  Future<void> excluir(int id);
}
