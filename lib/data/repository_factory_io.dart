import 'dart:io';

import 'package:sqflite/sqflite.dart' show databaseFactorySqflitePlugin;
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show DatabaseFactory, databaseFactoryFfi, sqfliteFfiInit;

import 'database_helper.dart';
import 'ocorrencia_repository.dart';
import 'sqlite_ocorrencia_repository.dart';

OcorrenciaRepository createRepository() {
  // Android, iOS e macOS usam o plugin nativo do sqflite.
  DatabaseFactory factory = databaseFactorySqflitePlugin;

  // No desktop (Windows/Linux) o sqflite precisa do driver FFI.
  // O binário do SQLite já vem embarcado no pacote: zero configuração.
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    factory = databaseFactoryFfi;
  }

  return SqliteOcorrenciaRepository(DatabaseHelper(factory: factory));
}
