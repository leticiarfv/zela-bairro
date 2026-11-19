import 'memory_ocorrencia_repository.dart';
import 'ocorrencia_repository.dart';
import 'seed_data.dart';

OcorrenciaRepository createRepository() {
  return MemoryOcorrenciaRepository(
    iniciais: seedOcorrencias(),
    delay: const Duration(milliseconds: 400),
  );
}
