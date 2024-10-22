import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

const String fileName = "todo2.db";

class DBprovider {
  DBprovider._init();

  static final DBprovider instance = DBprovider._init();

  static Database? _database;

  Future<sql.Database?> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDB(fileName);
    return _database;
  }

  Future createTables(sql.Database database, int version) async {
    await database.execute("""
CREATE TABLE todo(
id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
task TEXT,
source TEXT,
team TEXT,
creat_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)""");
  }

  Future<Database> _initializeDB(String fileName) async {
    final dbPath = await sql.getDatabasesPath();
    final path = join(dbPath, fileName);
    return await sql.openDatabase(path, version: 1, onCreate: createTables);
  }

  static Future<int> createTodo(
      String task, String source, String? team) async {
    final db = await instance.database;
    final data = {'task': task, 'source': source, 'team': team};

    final id = await db!
        .insert('todo', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> callAll() async {
    final db = await instance.database;
    return db!.query('todo', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getTodo(int id) async {
    final db = await instance.database;
    return db!.query('todo', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateTask(
      int id, String task, String? source, String? team) async {
    final db = await instance.database;
    final data = {
      'task': task,
      'source': source,
      'team': team,
      'creat_date': DateTime.now().toString()
    };

    final result =
        await db!.update('todo', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteTask(int id) async {
    final db = await instance.database;
    try {
      await db?.delete('todo', where: "id = ?", whereArgs: [id]);
    } catch (e) {
      debugPrint("Error trying to remove task: $e");
    }
  }
}
