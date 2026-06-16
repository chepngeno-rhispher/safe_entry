// lib/database.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseManager {
  // Singleton instance to prevent multiple connections from lagging the guard terminal
  static final LocalDatabaseManager instance = LocalDatabaseManager._init();
  static Database? _database;

  LocalDatabaseManager._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('safe_entry.db');
    return _database!;
  }

  // 📂 Opens the secure storage path inside the phone's local operating system
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB,
    );
  }

  // 📝 SQL Blueprints: Creates a structured relational table on the local storage partition
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE visitors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        hostUnit TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // 💾 SQL Insert Command: Writes guard registration inputs straight to the hardware storage disk
  Future<int> insertVisitor(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('visitors', row);
  }

  // 📊 SQL Query Command: Pulls all historical records to populate the guard's logbook ledger screen
  Future<List<Map<String, dynamic>>> queryAllVisitors() async {
    final db = await instance.database;
    return await db.query('visitors', orderBy: 'id DESC');
  }
}
