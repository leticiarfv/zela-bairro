import '../models/ocorrencia.dart';

/// Carga inicial (seed) gravada automaticamente na primeira execução,
/// para o app já abrir com dados de exemplo.
List<Ocorrencia> seedOcorrencias() {
  final agora = DateTime.now();
  return [
    Ocorrencia(
      titulo: 'Buraco grande na faixa de ônibus',
      descricao:
          'Buraco com cerca de 1 metro na faixa exclusiva. Ônibus e motos '
          'desviam bruscamente, risco de acidente.',
      categoria: Categoria.buraco,
      endereco: 'Av. Paulista, 1100',
      bairro: 'Bela Vista',
      prioridade: Prioridade.alta,
      riscoSeguranca: true,
      criadoEm: agora.subtract(const Duration(days: 6)),
    ),
    Ocorrencia(
      titulo: 'Poste apagado na praça',
      descricao:
          'Três postes da praça estão apagados há mais de uma semana. '
          'Moradores evitam passar à noite.',
      categoria: Categoria.iluminacao,
      endereco: 'Praça Benedito Calixto, s/n',
      bairro: 'Pinheiros',
      prioridade: Prioridade.media,
      status: StatusOcorrencia.emAndamento,
      riscoSeguranca: true,
      criadoEm: agora.subtract(const Duration(days: 4)),
    ),
    Ocorrencia(
      titulo: 'Entulho descartado em terreno',
      descricao:
          'Restos de obra e móveis velhos jogados no terreno baldio, '
          'atraindo ratos e mosquitos.',
      categoria: Categoria.lixo,
      endereco: 'Rua das Flores, 230',
      bairro: 'Capão Redondo',
      prioridade: Prioridade.media,
      criadoEm: agora.subtract(const Duration(days: 3)),
    ),
    Ocorrencia(
      titulo: 'Rua alaga em toda chuva forte',
      descricao:
          'Bueiro entupido. A água invade as casas da rua sempre que '
          'chove forte por mais de 30 minutos.',
      categoria: Categoria.alagamento,
      endereco: 'Rua Ribeirão Preto, 45',
      bairro: 'Jardim Pantanal',
      prioridade: Prioridade.alta,
      criadoEm: agora.subtract(const Duration(days: 2)),
    ),
    Ocorrencia(
      titulo: 'Calçada sem rampa de acesso',
      descricao:
          'Esquina sem rampa para cadeirantes em frente à UBS. '
          'Rampa foi construída após a solicitação.',
      categoria: Categoria.calcada,
      endereco: 'Rua Vergueiro, 3500',
      bairro: 'Vila Mariana',
      prioridade: Prioridade.baixa,
      status: StatusOcorrencia.resolvida,
      criadoEm: agora.subtract(const Duration(days: 10)),
    ),
  ];
}
