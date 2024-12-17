import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Singleton Instance
  factory DatabaseHelper() => instance;

  // Get Database Instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sewa_buku.db');
    return _database!;
  }

  // Initialize Database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create Table
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sewa_buku (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        alamat TEXT NOT NULL,
        nama_buku Text NOT NULL,
        tanggal_sewa TEXT NOT NULL,
        tanggal_kembali TEXT NOT NULL,
        total_bayar INTEGER NOT NULL
      )
    ''');
  }

  // Add Data
  Future<int> addSewa(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('sewa_buku', data);
  }

  // Get All Data (Ordered by ID Ascending)
  Future<List<Map<String, dynamic>>> getAllSewa() async {
    final db = await instance.database;
    return await db.query('sewa_buku', orderBy: 'id ASC');
  }

  // Update Data
  Future<int> updateSewa(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update(
      'sewa_buku',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  // Delete Data
  Future<int> deleteSewa(int id) async {
    final db = await instance.database;
    return await db.delete('sewa_buku', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> vacuumDatabase() async {
    final db = await instance.database;
    await db.execute('VACUUM');
    print("Database telah dioptimalkan dengan VACUUM.");
  }
}
