import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DBprovider {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
CREATE TABLE todo(
id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
task TEXT,
source TEXT,
team TEXT,
creat_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'TodoDb.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createTodo(
      String task, String source, String? team) async {
    final db = await DBprovider.db();
    final data = {'task': task, 'source': source, 'team': team};

    final id = await db.insert('todo', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> callAll() async {
    final db = await DBprovider.db();
    return db.query('todo', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getTodo(int id) async {
    final db = await DBprovider.db();
    return db.query('todo', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateTask(
      int id, String task, String? source, String? team) async {
    final db = await DBprovider.db();
    final data = {
      'task': task,
      'source': source,
      'team': team,
      'creat_date': DateTime.now().toString()
    };

    final result =
        await db.update('todo', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteTask(int id) async {
    final db = await DBprovider.db();
    try {
      await db.delete('todo', where: "id = ?", whereArgs: [id]);
    } catch (e) {
      debugPrint("Error trying to remove task: $e");
    }
  }
}
