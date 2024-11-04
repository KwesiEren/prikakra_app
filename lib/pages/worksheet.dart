import 'dart:async';

import 'package:firebase_test2/pages/updtetaskpage.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/todo_list.dart';
import '../models/db_provider.dart';
import '../models/task.dart';
import 'formpage.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({super.key});

  @override
  State<WorkArea> createState() => _WorkAreaState();
}

// This Codes are for the main body of the app where tasks
// and todos are displayed.

class _WorkAreaState extends State<WorkArea> {
  List<Todo?> _todoList = [];
  bool _isOnline = true;
  late StreamSubscription<InternetStatus> _internetSubscription;

  // The internet status is checked on startup
  // and the Local Todos is displayed.
  @override
  void initState() {
    super.initState();
    _initializeInternetChecker();
    _loadLocalTodos();
  }

  //Check if app is Connected to the Internet
  Future<void> _initializeInternetChecker() async {
    _internetSubscription =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      setState(() {
        _isOnline = status == InternetStatus.connected;
      });

      if (_isOnline) {
        //_syncLocalTodosToSupabase();
        print('Internet connected: Refresh to sync local todos with Supabase');
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

  // Sync local Todos to the Online database
  Future<void> _syncLocalTodosToSupabase() async {
    // Get only the unsynced todos
    final unsyncedTodos = _todoList.where((todo) => !todo!.isSynced).toList();

    if (unsyncedTodos.isEmpty) {
      print("No unsynced todos to upload.");
      return; // No unsynced todos
    }

    // Prepare data for upsert
    final upsertData = unsyncedTodos.map((todo) => todo!.toJson()).toList();

    final response =
        await Supabase.instance.client.from('todoTable').upsert(upsertData);

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

  // Toggle status of a Task on local databse and online database, if only online
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

  // Creates todos and adds it to the local database
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

  // Deletes todos from local database and online database, if only online
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

  // To navigate to the form page to create task
  void _navigateToAddTodoForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(onTodoAdded: _addTodo),
      ),
    );
  }

  // UI build code block:
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
          decoration:
              //Background Image block:
              BoxDecoration(
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
                          // Made it so that when you long press on a card, you can edit the tasks
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
                              // Edit Card contents here:
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
