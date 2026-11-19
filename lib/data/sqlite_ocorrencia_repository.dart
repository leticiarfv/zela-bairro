import '../models/ocorrencia.dart';
import 'database_helper.dart';
import 'ocorrencia_repository.dart';

/// Implementação do repositório com persistência local SQLite (sqflite).
class SqliteOcorrenciaRepository implements OcorrenciaRepository {
  SqliteOcorrenciaRepository(this._helper);

  final DatabaseHelper _helper;

  @override
  Future<List<Ocorrencia>> listar() async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.table,
      orderBy: 'criado_em DESC',
    );
    return rows.map(Ocorrencia.fromMap).toList();
  }

  @override
  Future<Ocorrencia> inserir(Ocorrencia ocorrencia) async {
    final db = await _helper.database;
    final map = ocorrencia.toMap()..remove('id');
    final id = await db.insert(DatabaseHelper.table, map);
    return ocorrencia.copyWith(id: id);
  }

  @override
  Future<void> atualizar(Ocorrencia ocorrencia) async {
    final id = ocorrencia.id;
    if (id == null) {
      throw ArgumentError('Não é possível atualizar uma ocorrência sem id.');
    }
    final db = await _helper.database;
    await db.update(
      DatabaseHelper.table,
      ocorrencia.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> excluir(int id) async {
    final db = await _helper.database;
    await db.delete(DatabaseHelper.table, where: 'id = ?', whereArgs: [id]);
  }
}
