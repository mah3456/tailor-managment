import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tailor/data/models/customer_model.dart';

import '../models/piece_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'shop.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        location TEXT NOT NULL
      )
    ''');



    await db.execute('''
      CREATE TABLE pieces(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_phone TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        price REAL NOT NULL,
        length REAL NOT NULL,
        width REAL NOT NULL,
        notes TEXT NOT NULL,
        paid_amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_phone) REFERENCES customers (phone) ON DELETE CASCADE
      )
    ''');
  }

  // Customer methods
  Future<int> insertCustomer(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('customers', row , conflictAlgorithm: ConflictAlgorithm.fail);
  }

  Future<List<Map<String, dynamic>>> queryAllCustomers() async {
    Database db = await database;
    return await db.query('customers');
  }

  Future<List<Map<String, dynamic>>> queryCustomersByName(String name) async {
    Database db = await database;
    return await db.query('customers', where: 'name LIKE ?', whereArgs: ['%$name%']);
  }

  Future<int> updateCustomer({required int id , required Map<String, dynamic> row}) async {
    Database db = await database;
    return await db.update('customers', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCustomer({required int id}) async {
    Database db = await database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // Piece methods
  Future<int> insertPiece({required Map<String, dynamic> row}) async {
    Database db = await database;
    return await db.insert('pieces', row);
  }

  Future<List<Map<String, dynamic>>> queryPiecesByCustomerId({required String phone}) async {
    Database db = await database;
    return await db.query('pieces', where: 'customer_phone = ?', whereArgs: [phone]);
  }

  Future<int> updatePiece({required Map<String, dynamic> row , required int id}) async {
    Database db = await database;
    return await db.update('pieces', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePiece({required int id}) async {
    Database db = await database;
    return await db.delete('pieces', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllData({required String table}) async {
    Database db = await database;
    return await db.delete(table);
  }


  Future<List<CustomerModel>> searchByName(String name) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customer',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return List.generate(maps.length, (i) => CustomerModel.fromMap(maps[i]));
  }

  Future<List<CustomerModel>> searchByPhone(String phone) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customer',
      where: 'phone LIKE ?',
      whereArgs: ['%$phone%'],
    );
    return List.generate(maps.length, (i) => CustomerModel.fromMap(maps[i]));
  }

  Future<List<CustomerModel>> search({required String search}) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customer',
      where: 'username LIKE ? OR meter LIKE ? OR phone LIKE ?',
      whereArgs: ['%$search%', '%$search%', '%$search%'],
    );
    return List.generate(maps.length, (i) => CustomerModel.fromMap(maps[i]));

  }



  // الحصول على جميع القطع
  Future<List<PieceModel>> getAllPieces() async {
    final db = await _instance.database;
    final maps = await db.query('pieces', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => PieceModel.fromMap(maps[i]));
  }

  // البحث عن قطع
  Future<List<PieceModel>> searchPieces(String query) async {
    final db = await _instance.database;
    final maps = await db.query(
      'pieces',
      where: 'name LIKE ? OR type LIKE ? OR notes LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => PieceModel.fromMap(maps[i]));
  }



}