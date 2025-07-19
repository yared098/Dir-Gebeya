import 'dart:convert';
import 'package:dirgebeya/Model/ProductModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDBHelper {
  static Database? _db;

  static Future<Database> initDb() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dirgebeya.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id TEXT PRIMARY KEY,
            data TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE earnings(
            type TEXT PRIMARY KEY,
            data TEXT
          );
        ''');
      },
    );

    return _db!;
  }

  static Future<void> cacheProducts(List<ProductModel> products) async {
    final db = await initDb();
    await db.delete('products');

    for (var p in products) {
      await db.insert(
        'products',
        {'id': p.productId, 'data': jsonEncode(p.toJson())},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<ProductModel>> getCachedProducts() async {
    final db = await initDb();
    final result = await db.query('products');
    return result.map((e) => ProductModel.fromJson(jsonDecode(e['data'] as String))).toList();
  }

  static Future<void> cacheEarnings(String type, Map<String, dynamic> data) async {
    final db = await initDb();
    await db.insert(
      'earnings',
      {'type': type, 'data': jsonEncode(data)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getCachedEarnings(String type) async {
    final db = await initDb();
    final result = await db.query('earnings', where: 'type = ?', whereArgs: [type]);
    if (result.isNotEmpty) {
      return jsonDecode(result.first['data'] as String);
    }
    return null;
  }
}
