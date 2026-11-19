import '../models/ocorrencia.dart';
import 'ocorrencia_repository.dart';

/// Repositório em memória. Usado como fallback quando o app roda no
/// navegador (Flutter Web não tem SQLite nativo) e nos testes.
/// Mantém a mesma API assíncrona do repositório SQLite.
class MemoryOcorrenciaRepository implements OcorrenciaRepository {
  MemoryOcorrenciaRepository({
    List<Ocorrencia> iniciais = const [],
    this.delay = Duration.zero,
  }) {
    for (final o in iniciais) {
      final id = _proximoId++;
      _dados[id] = o.copyWith(id: id);
    }
  }

  final Duration delay;
  final Map<int, Ocorrencia> _dados = {};
  int _proximoId = 1;

  Future<void> _simularLatencia() =>
      delay == Duration.zero ? Future.value() : Future.delayed(delay);

  @override
  Future<List<Ocorrencia>> listar() async {
    await _simularLatencia();
    final lista = _dados.values.toList()
      ..sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
    return lista;
  }

  @override
  Future<Ocorrencia> inserir(Ocorrencia ocorrencia) async {
    await _simularLatencia();
    final id = _proximoId++;
    final nova = ocorrencia.copyWith(id: id);
    _dados[id] = nova;
    return nova;
  }

  @override
  Future<void> atualizar(Ocorrencia ocorrencia) async {
    await _simularLatencia();
    final id = ocorrencia.id;
    if (id == null || !_dados.containsKey(id)) {
      throw StateError('Ocorrência não encontrada.');
    }
    _dados[id] = ocorrencia;
  }

  @override
  Future<void> excluir(int id) async {
    await _simularLatencia();
    _dados.remove(id);
  }
}
