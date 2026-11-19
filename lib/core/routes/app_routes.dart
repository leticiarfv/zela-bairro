import 'package:flutter/material.dart';

import '../../models/ocorrencia.dart';
import '../../screens/detalhes_screen.dart';
import '../../screens/formulario_screen.dart';
import '../../screens/shell_screen.dart';

/// Rotas nomeadas do app e passagem de argumentos entre telas.
///
/// Início, Ocorrências e Sobre são abas do [ShellScreen]. As rotas
/// `/lista` e `/sobre` abrem o shell já na aba certa (útil no navegador).
class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String lista = '/lista';
  static const String formulario = '/formulario';
  static const String detalhes = '/detalhes';
  static const String sobre = '/sobre';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case lista:
        return _page(
          const ShellScreen(abaInicial: ShellScreen.abaOcorrencias),
          settings,
        );
      case sobre:
        return _page(
          const ShellScreen(abaInicial: ShellScreen.abaSobre),
          settings,
        );
      case formulario:
        // Argumento opcional: ocorrência a ser editada.
        final ocorrencia = settings.arguments as Ocorrencia?;
        return _page(FormularioScreen(ocorrencia: ocorrencia), settings);
      case detalhes:
        // Argumento obrigatório: id da ocorrência selecionada.
        final id = settings.arguments as int?;
        if (id == null) return _page(const ShellScreen(), settings);
        return _page(DetalhesScreen(ocorrenciaId: id), settings);
      case home:
      default:
        return _page(const ShellScreen(), settings);
    }
  }

  static MaterialPageRoute<T> _page<T>(Widget child, RouteSettings settings) {
    return MaterialPageRoute<T>(builder: (_) => child, settings: settings);
  }
}
