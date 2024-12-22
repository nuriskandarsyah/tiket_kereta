import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tickets.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE tickets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_name TEXT NOT NULL,
            booking_date TEXT NOT NULL,
            from_station TEXT NOT NULL,
            to_station TEXT NOT NULL,
            price INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchTickets() async {
    final db = await database;
    return await db.query('tickets');
  }

  Future<void> insertTicket(Map<String, dynamic> ticket) async {
    final db = await database;
    await db.insert('tickets', ticket);
  }

  Future<void> updateTicket(int id, Map<String, dynamic> ticket) async {
    final db = await database;
    await db.update('tickets', ticket, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTicket(int id) async {
    final db = await database;
    await db.delete('tickets', where: 'id = ?', whereArgs: [id]);
  }
}
