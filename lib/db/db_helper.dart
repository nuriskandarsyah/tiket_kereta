import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flutter_crud.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

Future<void> addUser(String username, String password) async {
  final db = await instance.database;

  await db.insert(
    'users',
    {'username': username, 'password': password},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  Future<List<Map<String, dynamic>>> getUsers() async {
  final db = await instance.database;

  return await db.query('users');
}

Future<void> updateUser(int id, String username, String password) async {
  final db = await instance.database;

  await db.update(
    'users',
    {'username': username, 'password': password},  // Update username dan password
    where: 'id = ?',
    whereArgs: [id],
  );
}


Future<void> deleteUser(int id) async {
  final db = await instance.database;

  await db.delete(
    'users',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<bool> login(String username, String password) async {
  final db = await instance.database;

  final result = await db.query(
    'users',
    where: 'username = ? AND password = ?',
    whereArgs: [username, password],
  );

  return result.isNotEmpty;
}

}


