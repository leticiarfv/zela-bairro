import 'package:flutter/foundation.dart';

/// Categorias de problemas urbanos que o cidadão pode reportar.
enum Categoria {
  buraco('Buraco na via'),
  iluminacao('Iluminação pública'),
  lixo('Descarte irregular de lixo'),
  alagamento('Alagamento / Enchente'),
  calcada('Calçada / Acessibilidade'),
  sinalizacao('Sinalização / Semáforo'),
  outros('Outros');

  const Categoria(this.label);

  final String label;

  static Categoria fromName(String? name) => Categoria.values.firstWhere(
    (c) => c.name == name,
    orElse: () => Categoria.outros,
  );
}

/// Nível de urgência da ocorrência.
enum Prioridade {
  baixa('Baixa'),
  media('Média'),
  alta('Alta');

  const Prioridade(this.label);

  final String label;

  static Prioridade fromName(String? name) => Prioridade.values.firstWhere(
    (p) => p.name == name,
    orElse: () => Prioridade.media,
  );
}

/// Ciclo de vida da ocorrência.
enum StatusOcorrencia {
  aberta('Aberta'),
  emAndamento('Em andamento'),
  resolvida('Resolvida');

  const StatusOcorrencia(this.label);

  final String label;

  static StatusOcorrencia fromName(String? name) => StatusOcorrencia.values
      .firstWhere((s) => s.name == name, orElse: () => StatusOcorrencia.aberta);
}

/// Entidade principal: um problema urbano reportado por um cidadão.
@immutable
class Ocorrencia {
  const Ocorrencia({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.endereco,
    required this.bairro,
    required this.prioridade,
    this.status = StatusOcorrencia.aberta,
    this.riscoSeguranca = false,
    required this.criadoEm,
  });

  final int? id;
  final String titulo;
  final String descricao;
  final Categoria categoria;
  final String endereco;
  final String bairro;
  final Prioridade prioridade;
  final StatusOcorrencia status;
  final bool riscoSeguranca;
  final DateTime criadoEm;

  bool get resolvida => status == StatusOcorrencia.resolvida;

  /// Regra de negócio: ocorrência é urgente se tem prioridade alta
  /// ou oferece risco à segurança e ainda não foi resolvida.
  bool get urgente =>
      !resolvida && (prioridade == Prioridade.alta || riscoSeguranca);

  Ocorrencia copyWith({
    int? id,
    String? titulo,
    String? descricao,
    Categoria? categoria,
    String? endereco,
    String? bairro,
    Prioridade? prioridade,
    StatusOcorrencia? status,
    bool? riscoSeguranca,
    DateTime? criadoEm,
  }) {
    return Ocorrencia(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      endereco: endereco ?? this.endereco,
      bairro: bairro ?? this.bairro,
      prioridade: prioridade ?? this.prioridade,
      status: status ?? this.status,
      riscoSeguranca: riscoSeguranca ?? this.riscoSeguranca,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria.name,
      'endereco': endereco,
      'bairro': bairro,
      'prioridade': prioridade.name,
      'status': status.name,
      'risco_seguranca': riscoSeguranca ? 1 : 0,
      'criado_em': criadoEm.toIso8601String(),
    };
  }

  factory Ocorrencia.fromMap(Map<String, Object?> map) {
    return Ocorrencia(
      id: map['id'] as int?,
      titulo: map['titulo'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
      categoria: Categoria.fromName(map['categoria'] as String?),
      endereco: map['endereco'] as String? ?? '',
      bairro: map['bairro'] as String? ?? '',
      prioridade: Prioridade.fromName(map['prioridade'] as String?),
      status: StatusOcorrencia.fromName(map['status'] as String?),
      riscoSeguranca: (map['risco_seguranca'] as int? ?? 0) == 1,
      criadoEm:
          DateTime.tryParse(map['criado_em'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ocorrencia &&
          other.id == id &&
          other.titulo == titulo &&
          other.descricao == descricao &&
          other.categoria == categoria &&
          other.endereco == endereco &&
          other.bairro == bairro &&
          other.prioridade == prioridade &&
          other.status == status &&
          other.riscoSeguranca == riscoSeguranca &&
          other.criadoEm == criadoEm;

  @override
  int get hashCode => Object.hash(
    id,
    titulo,
    descricao,
    categoria,
    endereco,
    bairro,
    prioridade,
    status,
    riscoSeguranca,
    criadoEm,
  );

  @override
  String toString() => 'Ocorrencia($id, $titulo, ${status.name})';
}
