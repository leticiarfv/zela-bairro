import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'seed_data.dart';

/// Responsável por abrir o banco SQLite e criar a estrutura
/// automaticamente na primeira execução (onCreate + seed).
class DatabaseHelper {
  DatabaseHelper({required this.factory, this.path, this.seed = true});

  static const String dbName = 'zela_bairro.db';
  static const int dbVersion = 1;
  static const String table = 'ocorrencias';

  final DatabaseFactory factory;

  /// Caminho customizado (ex.: inMemoryDatabasePath nos testes).
  final String? path;
  final bool seed;
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = path ?? p.join(await factory.getDatabasesPath(), dbName);
    _db = await factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(version: dbVersion, onCreate: _onCreate),
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        categoria TEXT NOT NULL,
        endereco TEXT NOT NULL,
        bairro TEXT NOT NULL,
        prioridade TEXT NOT NULL,
        status TEXT NOT NULL,
        risco_seguranca INTEGER NOT NULL DEFAULT 0,
        criado_em TEXT NOT NULL
      )
    ''');

    if (!seed) return;
    final batch = db.batch();
    for (final o in seedOcorrencias()) {
      batch.insert(table, o.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
