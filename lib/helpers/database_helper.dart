import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Obtener una instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorites_database.db');
    return _database!;
  }

  // Inicializar la base de datos
  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) {
      throw Exception('Error initializing database: $e');
    }
  }

  // Crear la tabla
  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE favorites (
          id INTEGER PRIMARY KEY,
          userId INTEGER,
          title TEXT,
          body TEXT,
          imageUrl TEXT
        )
      ''');
    } catch (e) {
      throw Exception('Error creating database table: $e');
    }
  }

  // Insertar un favorito
  Future<int> insertFavorite(Post post) async {
    try {
      final db = await instance.database;
      return await db.insert('favorites', post.toMap());
    } catch (e) {
      throw Exception('Error inserting favorite: $e');
    }
  }

  // Obtener favoritos
  Future<List<Post>> getFavorites() async {
    try {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query('favorites');
      return List.generate(maps.length, (i) {
        return Post.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Error fetching favorites: $e');
    }
  }

  // Eliminar un favorito por ID
  Future<int> deleteFavorite(int id) async {
    try {
      final db = await instance.database;
      return await db.delete(
        'favorites',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting favorite: $e');
    }
  }

  // Cerrar la base de datos
  Future<void> close() async {
    try {
      final db = _database;
      if (db != null) {
        await db.close();
      }
    } catch (e) {
      throw Exception('Error closing database: $e');
    }
  }
}
