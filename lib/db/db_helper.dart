import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('train_ticket.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tabel stasiun
    await db.execute('''
    CREATE TABLE stations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    );
    ''');

    // Tabel rute
    await db.execute('''
    CREATE TABLE routes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      from_station_id INTEGER,
      to_station_id INTEGER,
      price INTEGER,
      FOREIGN KEY (from_station_id) REFERENCES stations (id),
      FOREIGN KEY (to_station_id) REFERENCES stations (id)
    );
    ''');

    // Tabel tiket
    await db.execute('''
    CREATE TABLE tickets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_name TEXT NOT NULL,
      from_station TEXT NOT NULL,
      to_station TEXT NOT NULL,
      booking_date TEXT NOT NULL,
      price INTEGER NOT NULL
    );
    ''');

    // Data awal stasiun
    await db.insert('stations', {'name': 'Jakarta'});
    await db.insert('stations', {'name': 'Bandung'});
    await db.insert('stations', {'name': 'Cirebon'});

    // Data awal rute
    await db.insert('routes', {
      'from_station_id': 1,
      'to_station_id': 2,
      'price': 250000
    });
    await db.insert('routes', {
      'from_station_id': 1,
      'to_station_id': 3,
      'price': 150000
    });
    await db.insert('routes', {
      'from_station_id': 2,
      'to_station_id': 1,
      'price': 200000
    });
    await db.insert('routes', {
      'from_station_id': 3,
      'to_station_id': 1,
      'price': 125000
    });
  }

  Future<List<Map<String, dynamic>>> fetchTickets() async {
    final db = await database;
    return await db.query('tickets');
  }

  Future<List<Map<String, dynamic>>> fetchRoutes() async {
    final db = await database;
    final routes = await db.rawQuery('''
      SELECT 
        r.id, 
        s1.name AS from_station, 
        s2.name AS to_station, 
        r.price
      FROM routes r
      JOIN stations s1 ON r.from_station_id = s1.id
      JOIN stations s2 ON r.to_station_id = s2.id
    ''');
    return routes;
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
