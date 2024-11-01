import 'dart:async';

import 'package:firebase_test2/pages/updtetaskpage.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/todo_list.dart';
import '../models/db_provider.dart';
import '../models/sb_db.dart';
import '../models/task.dart';
import 'formpage.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({super.key});

  @override
  State<WorkArea> createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  List<Todo?> _todoList = [];
  bool _isOnline = true;
  late StreamSubscription<InternetStatus> _internetSubscription;

  @override
  void initState() {
    super.initState();
    _initializeInternetChecker();
    _loadLocalTodos(); // Load todos from local DB on initialization
  }

  Future<void> _initializeInternetChecker() async {
    _internetSubscription =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      setState(() {
        _isOnline = status == InternetStatus.connected;
      });

      if (_isOnline) {
        _syncLocalTodosToSupabase();
        print('Internet connected: syncing local todos with Supabase');
      } else {
        print('No internet connection');
      }
    });
  }

  @override
  void dispose() {
    _internetSubscription.cancel();
    super.dispose();
  }

  // Fetch all todos from local database
  Future<void> _loadLocalTodos() async {
    final todos = await AppDB.instnc.getAllTodo();
    setState(() {
      _todoList = todos.map((todo) {
        todo?.isSynced = false; // Mark as unsynced when loaded
        return todo;
      }).toList();
    });
  }

  Future<void> _fetchTodos() async {
    // Fetch local todos
    final localTodos = await AppDB.instnc.getAllTodo();

    // Fetch todos from Supabase
    final supabaseTodos = await _fetchTodosFromSupabase();
    Set<String?> supabaseTodoTitles =
        supabaseTodos.map((todo) => todo.title).toSet();

    // Identify todos that are only in the local database
    List<Todo?> todosToUpload = localTodos
        .where((todo) => !supabaseTodoTitles.contains(todo!.title))
        .toList();

    // Upload the missing todos to Supabase
    for (var todo in todosToUpload) {
      await SupaDB.addtoSB(todo!);
      print('Uploaded new todo to Supabase: ${todo.title}');
    }

    // Set the local todo list to the latest data
    setState(() {
      _todoList = localTodos;
    });

    print('Local DB refreshed and synced with Supabase.');
  }

  Future<void> _syncLocalTodosToSupabase() async {
    // Get only the unsynced todos
    final unsyncedTodos = _todoList.where((todo) => !todo!.isSynced).toList();

    if (unsyncedTodos.isEmpty) {
      print("No unsynced todos to upload.");
      return; // No unsynced todos
    }

    // Prepare data for upsert
    final upsertData = unsyncedTodos.map((todo) => todo!.toJson()).toList();

    final response = await Supabase.instance.client
        .from('todoTable')
        .upsert(upsertData);

    if (response.error != null) {
      print("Failed to sync todos: ${response.error!.message}");
    } else {
      // Mark todos as synced
      for (var todo in unsyncedTodos) {
        todo!.isSynced = true; // Mark as synced
      }
      print("Successfully synced todos.");
    }

    _loadLocalTodos(); // Refresh local todos list after syncing
  }


  Future<List<Todo>> _fetchTodosFromSupabase() async {
    final response = await Supabase.instance.client.from('todoTable').select();

    final data = response as List<dynamic>?;
    if (data == null) {
      print("No data found in Supabase table.");
      return [];
    }

    // Map JSON data to Todo objects
    return data.map((json) => Todo.fromJson(json)).toList();
  }

  // Toggle status of a todo item and update in local database and Supabase if online
  void _toggleTodoStatus(int index) async {
    final updatedStatus = !_todoList[index]!.status;
    setState(() {
      _todoList[index]!.status = updatedStatus;
    });

    await AppDB.instnc.updateTodoStatus(_todoList[index]!.id, updatedStatus);

    if (_isOnline) {
      final response = await Supabase.instance.client
          .from('todoTable')
          .update({'status': updatedStatus ? 1 : 0}).eq(
              'title', _todoList[index]!.title);

      if (response.error != null) {
        print(
            "Failed to update status in Supabase: ${response.error!.message}");
      } else {
        print(
            "Successfully updated status for Todo: ${_todoList[index]!.title}");
      }
    }
  }

  // Add new todo to local DB and refresh the list
  void _addTodo(Todo newTodo) async {
    await AppDB.instnc.addTodo(newTodo);
    _loadLocalTodos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Todo added successfully!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.amberAccent,
      ),
    );
  }

  // Delete todo from local DB and Supabase
  void _deleteTodoById(int? id) async {
    await AppDB.instnc.deleteTodoById(id!);
    _loadLocalTodos();

    if (_isOnline) {
      final response = await Supabase.instance.client
          .from('todoTable')
          .delete()
          .eq('id', id);
      if (response.error != null) {
        print("Failed to delete from Supabase: ${response.error!.message}");
      } else {
        print("Successfully deleted todo from Supabase");
      }
    }
  }

  void _navigateToAddTodoForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(onTodoAdded: _addTodo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: const Text('To-Do'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Container(
          width: screen.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: Image.asset('assets/bg3.png').image,
            ),
          ),
          child: Center(
            child: RefreshIndicator(
              onRefresh: //_loadLocalTodos,
                  _syncLocalTodosToSupabase,
              child: _todoList.isEmpty
                  ? const Text(
                      'The list is empty!',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white10,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _todoList.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, index) {
                        return Card(
                          margin: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
                          child: GestureDetector(
                            onLongPress: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EditTodoScreen(
                                    todo: _todoList[index],
                                    onTodoUpdated: (updatedTodo) {
                                      setState(() {
                                        _todoList[index] = updatedTodo;
                                      });
                                      _syncLocalTodosToSupabase();
                                    },
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              title: toDolist(
                                taskName: _todoList[index]!.title,
                                taskCompleted: _todoList[index]!.status,
                                onChanged: (value) => _toggleTodoStatus(index),
                                taskDetail: _todoList[index]!.details,
                              ),
                              subtitle: Text(_todoList[index]!.user),
                              trailing: IconButton(
                                onPressed: () =>
                                    _deleteTodoById(_todoList[index]!.id),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        hoverColor: Colors.greenAccent,
        onPressed: _navigateToAddTodoForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
