import 'package:flutter/material.dart';

/// Objetivo de Desenvolvimento Sustentável (ONU) atendido pelo app.
class Ods {
  const Ods({
    required this.numero,
    required this.titulo,
    required this.cor,
    required this.comoAtendemos,
  });

  final int numero;
  final String titulo;
  final Color cor;
  final String comoAtendemos;
}

/// Cores oficiais dos ODS da ONU.
const List<Ods> odsAtendidos = [
  Ods(
    numero: 11,
    titulo: 'Cidades e Comunidades Sustentáveis',
    cor: Color(0xFFFD9D24),
    comoAtendemos:
        'O cidadão registra os problemas de infraestrutura do bairro '
        'e acompanha a manutenção.',
  ),
  Ods(
    numero: 3,
    titulo: 'Saúde e Bem-Estar',
    cor: Color(0xFF4C9F38),
    comoAtendemos:
        'Reduz riscos de acidentes e focos de doenças causados por '
        'buracos, lixo acumulado e água parada.',
  ),
  Ods(
    numero: 13,
    titulo: 'Ação Contra a Mudança Global do Clima',
    cor: Color(0xFF3F7E44),
    comoAtendemos: 'Mapeia os pontos de alagamento da cidade.',
  ),
];
