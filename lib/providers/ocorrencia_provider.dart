import 'package:flutter/foundation.dart';

import '../data/ocorrencia_repository.dart';
import '../models/ocorrencia.dart';

/// Estado global das ocorrências. Concentra as regras de negócio e
/// notifica a UI (Consumer / context.watch) a cada mudança.
class OcorrenciaProvider extends ChangeNotifier {
  OcorrenciaProvider(this._repository);

  final OcorrenciaRepository _repository;

  List<Ocorrencia> _ocorrencias = [];
  bool _isLoading = false;
  bool _carregouUmaVez = false;
  String? _erro;
  StatusOcorrencia? _filtroStatus;
  String _busca = '';

  // ---------- Getters de estado ----------
  List<Ocorrencia> get ocorrencias => List.unmodifiable(_ocorrencias);
  bool get isLoading => _isLoading;
  bool get carregouUmaVez => _carregouUmaVez;
  String? get erro => _erro;
  StatusOcorrencia? get filtroStatus => _filtroStatus;

  String get busca => _busca;

  /// Lista exibida na tela: aplica o filtro de status e a busca por
  /// título ou bairro (sem diferenciar maiúsculas e acentos).
  List<Ocorrencia> get ocorrenciasFiltradas {
    final termo = _normalizar(_busca.trim());
    return List.unmodifiable(
      _ocorrencias.where((o) {
        if (_filtroStatus != null && o.status != _filtroStatus) return false;
        if (termo.isEmpty) return true;
        return _normalizar(o.titulo).contains(termo) ||
            _normalizar(o.bairro).contains(termo);
      }),
    );
  }

  /// Ocorrências urgentes, da mais grave para a menos grave.
  List<Ocorrencia> get listaUrgentes {
    final lista = _ocorrencias.where((o) => o.urgente).toList()
      ..sort((a, b) => b.prioridade.index.compareTo(a.prioridade.index));
    return List.unmodifiable(lista);
  }

  // ---------- Indicadores do dashboard ----------
  int get total => _ocorrencias.length;
  int contarPorStatus(StatusOcorrencia s) =>
      _ocorrencias.where((o) => o.status == s).length;
  int get abertas => contarPorStatus(StatusOcorrencia.aberta);
  int get emAndamento => contarPorStatus(StatusOcorrencia.emAndamento);
  int get resolvidas => contarPorStatus(StatusOcorrencia.resolvida);
  int get urgentes => _ocorrencias.where((o) => o.urgente).length;

  /// Percentual (0 a 1) de ocorrências já resolvidas.
  double get taxaResolucao => total == 0 ? 0 : resolvidas / total;

  /// Quantidade de ocorrências por categoria, apenas as que têm registros,
  /// ordenadas da maior para a menor.
  Map<Categoria, int> get porCategoria {
    final mapa = <Categoria, int>{};
    for (final o in _ocorrencias) {
      mapa[o.categoria] = (mapa[o.categoria] ?? 0) + 1;
    }
    final entradas = mapa.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entradas);
  }

  Ocorrencia? buscarPorId(int id) {
    for (final o in _ocorrencias) {
      if (o.id == id) return o;
    }
    return null;
  }

  // ---------- Ações ----------
  void filtrarPorStatus(StatusOcorrencia? status) {
    if (_filtroStatus == status) return;
    _filtroStatus = status;
    notifyListeners();
  }

  void buscar(String termo) {
    if (_busca == termo) return;
    _busca = termo;
    notifyListeners();
  }

  Future<void> carregar() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    try {
      _ocorrencias = await _repository.listar();
    } catch (e) {
      _erro = 'Não foi possível carregar as ocorrências.';
      debugPrint('Erro ao carregar: $e');
    } finally {
      _isLoading = false;
      _carregouUmaVez = true;
      notifyListeners();
    }
  }

  Future<bool> adicionar(Ocorrencia ocorrencia) async {
    return _executar(() async {
      final nova = await _repository.inserir(ocorrencia);
      _ocorrencias = [nova, ..._ocorrencias];
    }, 'Não foi possível salvar a ocorrência.');
  }

  Future<bool> atualizar(Ocorrencia ocorrencia) async {
    return _executar(() async {
      await _repository.atualizar(ocorrencia);
      _ocorrencias = [
        for (final o in _ocorrencias) o.id == ocorrencia.id ? ocorrencia : o,
      ];
    }, 'Não foi possível atualizar a ocorrência.');
  }

  Future<bool> alterarStatus(int id, StatusOcorrencia status) async {
    final atual = buscarPorId(id);
    if (atual == null) return false;
    return atualizar(atual.copyWith(status: status));
  }

  Future<bool> remover(int id) async {
    return _executar(() async {
      await _repository.excluir(id);
      _ocorrencias = _ocorrencias.where((o) => o.id != id).toList();
    }, 'Não foi possível excluir a ocorrência.');
  }

  Future<bool> _executar(
    Future<void> Function() operacao,
    String mensagemErro,
  ) async {
    _erro = null;
    try {
      await operacao();
      return true;
    } catch (e) {
      _erro = mensagemErro;
      debugPrint('$mensagemErro $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  static String _normalizar(String texto) {
    const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const para = 'aaaaaeeeeiiiiooooouuuuc';
    final buffer = StringBuffer();
    for (final ch in texto.toLowerCase().split('')) {
      final i = de.indexOf(ch);
      buffer.write(i >= 0 ? para[i] : ch);
    }
    return buffer.toString();
  }
}
