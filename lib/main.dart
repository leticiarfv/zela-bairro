import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/ocorrencia_repository.dart';
import 'data/repository_factory.dart';
import 'providers/ocorrencia_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = createRepository();
  runApp(ZelaBairroBootstrap(repository: repository));
}

/// Injeta as dependências (repositório + Provider) acima do MaterialApp.
class ZelaBairroBootstrap extends StatelessWidget {
  const ZelaBairroBootstrap({super.key, required this.repository});

  final OcorrenciaRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<OcorrenciaRepository>.value(value: repository),
        ChangeNotifierProvider(
          create: (_) => OcorrenciaProvider(repository)..carregar(),
        ),
      ],
      child: const ZelaBairroApp(),
    );
  }
}
