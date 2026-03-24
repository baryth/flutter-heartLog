import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/measurement.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'blood_pressure.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE measurements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL,
        pulse INTEGER NOT NULL,
        datetime TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertMeasurement(Measurement measurement) async {
    final db = await database;
    return db.insert('measurements', measurement.toMap());
  }

  Future<List<Measurement>> getAllMeasurements() async {
    final db = await database;
    final maps = await db.query('measurements', orderBy: 'datetime DESC');
    return maps.map(Measurement.fromMap).toList();
  }

  Future<int> updateMeasurement(Measurement measurement) async {
    final db = await database;
    return db.update(
      'measurements',
      measurement.toMap(),
      where: 'id = ?',
      whereArgs: [measurement.id],
    );
  }

  Future<int> deleteMeasurement(int id) async {
    final db = await database;
    return db.delete('measurements', where: 'id = ?', whereArgs: [id]);
  }
}
