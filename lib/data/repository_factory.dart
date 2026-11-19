// Escolhe a implementação do repositório conforme a plataforma:
// - Android, iOS, Windows, macOS, Linux -> SQLite (sqflite / sqflite_ffi)
// - Web -> repositório em memória com a mesma carga inicial
export 'repository_factory_io.dart'
    if (dart.library.js_interop) 'repository_factory_web.dart';
