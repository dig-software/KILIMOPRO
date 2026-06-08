import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'expense_model.dart';

class DatabaseHelper {
  // Define database name and version
  static const _databaseName = "FarmTracker.db";
  static const _databaseVersion = 1;

  // Singleton instance initialization
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // Global database getter with lazy initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Opens the database file path on the device
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database tables
  Future _onCreate(Database db, int version) async {
    // 1. Create Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // 2. Create Feedings Table
    await db.execute('''
      CREATE TABLE feedings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        feedType TEXT NOT NULL,
        quantity TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // =========================================================================
  // EXPENSES METHODS (Uses the typed Expense Model Class)
  // =========================================================================

  // Insert a new row into the expenses table
  Future<int> insertExpense(Expense expense) async {
    Database db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  // Retrieve all records from the expenses table
  Future<List<Expense>> fetchAllExpenses() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('expenses', orderBy: 'date DESC');
    
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Delete an expense record by its Primary Key ID
  Future<int> deleteExpense(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================================================================
  // FEEDING METHODS (Uses Raw Maps as structured in your Feeding UI code)
  // =========================================================================

  // Insert a raw map row into the feedings table
  Future<int> insertFeeding(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('feedings', row);
  }

  // Retrieve all records from the feedings table as raw maps
  Future<List<Map<String, dynamic>>> fetchAllFeedings() async {
    Database db = await instance.database;
    return await db.query('feedings', orderBy: 'date DESC');
  }

  // Delete a feeding record by its Primary Key ID
  Future<int> deleteFeeding(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'feedings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}