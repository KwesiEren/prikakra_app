import 'dart:async';

import 'package:firebase_test2/components/view_list.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/db_provider.dart';
import '../models/sb_auth.dart';
import '../models/sb_db.dart';
import '../models/task.dart';

class AllTask extends StatefulWidget {
  const AllTask({super.key});

  @override
  State<AllTask> createState() => _AllTaskState();
}

class _AllTaskState extends State<AllTask> {
  Timer? _timer;
  List<Todo?> _todoList = [];
  bool _isOnline = true;
  bool isLoading = true;
  final _auth = SBAuth();

  void initState() {
    super.initState();
    // _initializeInternetChecker(); //Check internet status on init
    //loadData();
    _loadLocalTodos(); // Call all local database task on init
    // _checkUserInDatabase(); // Call user email on init
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _runPeriodicFunction();
    });
  }

  void _runPeriodicFunction() async {
    // Place your logic here
    await _fetchMissingTodosFromSupabase();
    await _syncLocalTodosToSupabase();
    debugPrint('Sync is running every 30 seconds');
  }

  //Fetch all todos from local database
  Future<List> _loadLocalTodos() async {
    setState(() {
      isLoading = true;
    });
    try {
      final todos = await AppDB.instnc.getAllTodo();
      setState(() {
        _todoList = todos.map((todo) {
          todo?.isSynced = false; // Mark as unsynced when loaded
          return todo;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
    return _todoList;
  }

  //Fetch missing todos from Supabase:
  Future<void> _fetchMissingTodosFromSupabase() async {
    final response = await SupaDB.getAllSB();

    // Verify if response is in List<Map<String, dynamic>> format or List<Todo>
    if (response is List<Map<String, dynamic>>) {
      // If response is in map format, parse it into Todo objects
      final supabaseTodos = response
          .map((json) => Todo.fromJson(json as Map<String, dynamic>))
          .toList();

      // Compare and find missing todos
      final localTodos = await AppDB.instnc.getAllTodo();
      final missingTodos = supabaseTodos.where((supabaseTodo) {
        return !localTodos.any((localTodo) => localTodo!.id == supabaseTodo.id);
      }).toList();

      // Add missing todos to the local database
      for (var task in missingTodos) {
        await AppDB.instnc.addTodo(task as Todo);
      }
    } else if (response is List<Todo>) {
      // If response is already a list of Todo objects, use it directly
      final supabaseTodos = response;

      final localTodos = await AppDB.instnc.getAllTodo();
      final missingTodos = supabaseTodos.where((supabaseTodo) {
        return !localTodos.any((localTodo) => localTodo!.id == supabaseTodo.id);
      }).toList();

      for (var todo in missingTodos) {
        await AppDB.instnc.addTodo(todo);
        //await SupaDB.updateSyncSB();
      }
    } else {
      throw Exception("Unexpected response format from Supabase");
    }

    debugPrint("Missing todos have been successfully pulled from Supabase.");

    // Refresh the UI with the latest todos
    setState(() {
      _loadLocalTodos();
    });
  }

  // Sync local Todos to the Online database
  Future<void> _syncLocalTodosToSupabase() async {
    final unsyncedTodos = _todoList.where((todo) => !todo!.isSynced).toList();

    if (unsyncedTodos.isEmpty) {
      debugPrint("No unsynced todos to upload.");
      return;
    }

    // Prepare data for upsert with isSynced set to true for Supabase
    final upsertData = unsyncedTodos.map((todo) {
      final json = todo!.toJson();
      json['isSynced'] = true; // Set isSynced to true for Supabase
      return json;
    }).toList();

    final response =
        await Supabase.instance.client.from('todoTable').upsert(upsertData);

    if (response.error != null) {
      debugPrint("Failed to sync todos: ${response.error!.message}");
    } else {
      // Mark todos as synced in the local database
      for (var todo in unsyncedTodos) {
        todo!.isSynced = true;
        await AppDB.instnc.updateTodoSyncStatus(todo.id!, true);
      }
      debugPrint("Successfully synced todos.");
    }

    setState(() {
      _loadLocalTodos(); // Refresh local todos list after syncing
    });
  }

  // Toggle status of a Task on local databse and online database, if only online
  void _toggleTodoStatus(int index) async {
    final updatedStatus = !_todoList[index]!.status;
    setState(() {
      _todoList[index]!.status = updatedStatus;
    });

    await AppDB.instnc
        .updateTodoStatus(_todoList[index]!.id as String, updatedStatus);

    if (_isOnline) {
      final response = await Supabase.instance.client
          .from('todoTable')
          .update({'status': updatedStatus ? 1 : 0}).eq(
              'title', _todoList[index]!.title);

      if (response.error != null) {
        debugPrint(
            "Failed to update status in Supabase: ${response.error!.message}");
      } else {
        debugPrint(
            "Successfully updated status for Todo: ${_todoList[index]!.title}");
      }
    }
  }

  // Deletes todos from local database and online database, if only online
  void _deleteTodoById(String? id) async {
    await AppDB.instnc.deleteTodoById(id!);
    _loadLocalTodos();

    if (_isOnline) {
      final response = await Supabase.instance.client
          .from('todoTable')
          .delete()
          .eq('id', id);
      if (response.error != null) {
        debugPrint(
            "Failed to delete from Supabase: ${response.error!.message}");
      } else {
        debugPrint("Successfully deleted todo from Supabase");
      }
    }
  }

  @override
  void dispose() {
    // _internetSubscription.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Center(
      child: SafeArea(
        child: Container(
          width: screen.width,
          decoration:
              //Background Image block:
              const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover, image: AssetImage('assets/bg3.jpg')),
          ),
          child: Center(
            child: RefreshIndicator(
              onRefresh: _syncLocalTodosToSupabase,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _todoList.isEmpty
                      ? const Text(
                          'The list is empty!',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _todoList.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (BuildContext context, index) {
                            return Card(
                              // Made it so that when you long press on a card, you can edit the tasks
                              margin: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              child: ListTile(
                                // Edit Card contents here:
                                title: ViewTask(
                                  taskName: _todoList[index]!.title,
                                  taskDetail: _todoList[index]!.details,
                                ),
                                subtitle: Text(_todoList[index]!.user),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
