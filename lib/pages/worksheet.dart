import 'dart:async';
import 'dart:io';

import 'package:firebase_test2/components/button2.dart';
import 'package:firebase_test2/components/button3.dart';
import 'package:firebase_test2/models/sb_db.dart';
import 'package:firebase_test2/pages/updtetaskpage.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/todo_list.dart';
import '../models/db_provider.dart';
import '../models/sb_auth.dart';
import '../models/task.dart';
import 'formpage.dart';

class WorkArea extends StatefulWidget {
  String userName;
  final String userEmail;
  final String userPassword;
  WorkArea(
      {required this.userEmail,
      required this.userPassword,
      super.key,
      required this.userName});

  @override
  State<WorkArea> createState() => _WorkAreaState();
}

// This Codes are for the main body of the app where tasks
// and todos are displayed.

class _WorkAreaState extends State<WorkArea> {
  DateTime? _lastPressedAt;
  Timer? _timer;
  List<Todo?> _todoList = [];
  bool _isOnline = true;
  bool isLoading = true;
  bool isUserInDatabase = false;
  final _auth = SBAuth();

  late StreamSubscription<InternetStatus> _internetSubscription;

  // The internet status is checked on startup
  // and the Local Todos is displayed.
  @override
  void initState() {
    super.initState();
    _initializeInternetChecker(); //Check internet status on init
    //loadData();
    _loadLocalTodos(); // Call all local database task on init
    _checkUserInDatabase(); // Call user email on init
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _runPeriodicFunction();
    });
    _syncLocalTodosToSupabase();
  }

  //To create a auto sync every period of 5s:
  void _runPeriodicFunction() async {
    // Place your logic here
    await _fetchMissingTodosFromSupabase();
    debugPrint('Sync is running every 30 seconds');
  }

  //Check if app is Connected to the Internet
  Future<void> _initializeInternetChecker() async {
    _internetSubscription =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      setState(() {
        _isOnline = status == InternetStatus.connected;
      });

      if (_isOnline) {
        debugPrint(
            'Internet connected: Refresh to sync local todos with Supabase');
      } else {
        debugPrint('No internet connection');
      }
    });
  }

// Check if the user is in the database on app startup
  Future<void> _checkUserInDatabase() async {
    final response = await Supabase.instance.client
        .from('user_credentials')
        .select()
        .eq('email', widget.userEmail)
        .single();

    setState(() {
      isUserInDatabase = response != null;
    });
  }

  @override
  void dispose() {
    _internetSubscription.cancel();
    _timer?.cancel();
    super.dispose();
  }

  // Fetch all todos from local database
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

  Future<void> loadData() async {
    await _loadLocalTodos();
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
      for (var todo in missingTodos) {
        await AppDB.instnc.addTodo(todo);
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

    await AppDB.instnc.updateTodoStatus(_todoList[index]!.id, updatedStatus);

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
        debugPrint(
            "Failed to delete from Supabase: ${response.error!.message}");
      } else {
        debugPrint("Successfully deleted todo from Supabase");
      }
    }
  }

  Future<void> _closesession() async {
    if (isUserInDatabase) {
      await _auth.logout();
      setState(() {
        isUserInDatabase = false;
      });
    }
    Navigator.pushNamed(context, '/login');
  }

  // To navigate to the form page to create task
  void _navigateToAddTodoForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(
          onTodoAdded: _addTodo,
          userName: widget.userName,
        ),
      ),
    );
  }

  // UI build code block:
  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > Duration(seconds: 2)) {
          // If the last press was more than 2 seconds ago, reset the timer
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Press back again to exit')),
          );
          return false; // Prevent the default back button behavior
        }
        return exit(0); // Exit the app
      },
      child: Scaffold(
        // APP BAR
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('To-Do'),
          centerTitle: true,
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black,
        ),

        //Codes for Drawer begin here
        endDrawer: SafeArea(
          child: Drawer(
            child: ListView(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const CircleAvatar(
                        backgroundImage: AssetImage('assets/bg2.jpg'),
                        radius: 80,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        isUserInDatabase
                            ? widget.userName
                            : 'Please Sign In', //Display current logged in user email here.
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: _isOnline
                                      ? Colors.green
                                      : Colors
                                          .grey, //Turns grey to indicate user is not online.
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text('Online'),
                          ]),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  onTap: () {},
                  title: ButnTyp2(
                      text: 'Edit User Information',
                      size: 20,
                      btnColor: Colors.greenAccent,
                      borderRadius: 5),
                ),
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  onTap: () {},
                  title: ButnTyp2(
                      text: 'Statistics',
                      size: 20,
                      btnColor: Colors.greenAccent,
                      borderRadius: 5),
                ),
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  onTap: () {},
                  title: ButnTyp2(
                      text: 'Terms and Conditions',
                      size: 20,
                      btnColor: Colors.greenAccent,
                      borderRadius: 5),
                ),
                const SizedBox(
                  height: 100,
                ),
                GestureDetector(
                  onTap: () {
                    _closesession();
                    //Navigator.pushNamed(context, '/login');
                  },
                  //isUserInDatabase ? 'Log out' : 'Log in',
                  child: ButnTyp3(
                      text: isUserInDatabase ? 'Log out' : 'Log in',
                      size: 20,
                      btnColor: Colors.red,
                      borderRadius: 5),
                )
              ],
            ),
          ),
        ),
        //DRAWER ENDS HERE

        //Body Codes Begin Here
        body: SafeArea(
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
                                      onChanged: (value) =>
                                          _toggleTodoStatus(index),
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
        //BODY ENDS HERE

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          hoverColor: Colors.greenAccent,
          onPressed: _navigateToAddTodoForm,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
