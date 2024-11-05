import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'task.dart';

// Here is my Local database handler codes.
// Created a database 'todoDB' and table 'todoTable':
const String fileName = "todoDB.db";

class AppDB {
  //Initialize Database:
  AppDB._init();

  static final AppDB instnc = AppDB._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _startDB(fileName);
    return _database!;
  }

  //Creating table and its column:
  Future _create(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableName(
      $idFN INTEGER PRIMARY KEY AUTOINCREMENT,
      $titleFN TEXT NOT NULL,
      $detailsFN TEXT,
      $taskTypeFN TEXT NOT NULL,
      $userFN TEXT NOT NULL,
      $teamFN TEXT,
      $crtedDateFN TEXT NOT NULL,
      $statusFN BOOLEAN NOT NULL,
      $isSyncedFN BOOLEAN NOT NULL
    )
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

  //Creating CRUD operations:

  Future<Todo> addTodo(Todo todo) async {
    //Insert entry into todoTable
    final db = await instnc.database;
    final id = await db.insert(tableName, todo.toJson());

    print("Inserted Todo with ID: $id");

    return todo.copyWith(id: id);
  }

  Future<List<Todo?>> getAllTodo() async {
    //Fetch all elements in table
    final db = await instnc.database;
    final result = await db.query(tableName, orderBy: "$idFN ASC");

    return result.map((json) => Todo.fromJson(json)).toList();
  }

  Future<void> updateTodoStatus(int? id, bool status) async {
    //Update element in status column by ID
    final db = await database;
    await db.update(
      tableName,
      {'$statusFN': status ? 1 : 0}, // Convert boolean to int for SQLite
      where: '$idFN = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTodoSyncStatus(int? id, bool isSynced) async {
    final db = await database;
    await db.update(
      'todos',
      {'isSynced': isSynced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTodo(Todo todo) async {
    //Update element in table by ID
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
    //Delete element in table by ID
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
    //Close Database
    final db = await instnc.database;
    return db.close();
  }
}
