import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'task.dart';

const String fileName = "todoDB.db";

class AppDB {
  AppDB._init();

  static final AppDB instnc = AppDB._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _startDB(fileName);
    return _database!;
  }

  Future _create(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableName(
    $idFN INTEGER PRIMARY KEY AUTOINCREMENT,
    $titleFN TEXT NOT NULL,
    $detailsFN TEXT,
    $taskTypeFN TEXT NOT NULL,
    $userFN TEXT NOT NULL,
    $teamFN TEXT,
    $crtedDateFN  TEXT NOT NULL,
    $statusFN BOOLEAN NOT NULL)
    ''');
  }

  Future<Database> _startDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _create,
      onOpen: (db) {
        print("Database opened at: $path");
      },
      singleInstance: true,
    );
  }

  Future<Todo> addTodo(Todo todo) async {
    final db = await instnc.database;
    final id = await db.insert(tableName, todo.toJson());

    print("Inserted Todo with ID: $id");

    return todo.copyWith(id: id);
  }

  Future<List<Todo?>> getAllTodo() async {
    final db = await instnc.database;
    final result = await db.query(tableName, orderBy: "$idFN ASC");

    return result.map((json) => Todo.fromJson(json)).toList();
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await instnc.database;
    final result = await db.update(
      tableName,
      todo.toJson(),
      where: '$idFN = ?',
      whereArgs: [todo.id],
    );
    print("Updated Todo with ID: ${todo.id}, Rows affected: $result");
    return result;
  }

  Future<int> deleteTodoById(int id) async {
    final db = await instnc.database;
    final result = await db.delete(
      tableName,
      where: '$idFN = ?',
      whereArgs: [id],
    );
    print("Deleted Todo with ID: $id, Rows affected: $result");
    return result;
  }

  Future<void> closeDB() async {
    final db = await instnc.database;
    return db.close();
  }
}
