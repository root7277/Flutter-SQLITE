import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class NoteDatabase {
  static final NoteDatabase instance = NoteDatabase._init();

  static Database? _database;

  NoteDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL
      )
    ''');
  }

  Future<void> create(Map<String, dynamic> note) async {
    final db = await instance.database;
    await db.insert('notes', note);
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final db = await instance.database;
    return await db.query('notes', orderBy: 'id DESC');
  }

  Future<void> update(Map<String, dynamic> note) async {
    final db = await instance.database;
    await db.update('notes', note, where: 'id = ?', whereArgs: [note['id']]);
  }

  Future<void> delete(int id) async {
    final db = await instance.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
