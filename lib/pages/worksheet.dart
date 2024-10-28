import 'package:firebase_test2/pages/updtetaskpage.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final todos = await AppDB.instnc.getAllTodo();
    final todoSB = await SupaDB.getAllSB();
    print(_todoList);

    print('Online DB fetched');

    setState(() {
      _todoList = todoSB;
    });
    print('$_todoList');
  }

  Future<void> _fetchTask() async {
    final todos = await AppDB.instnc.getAllTodo();
    final todoSB = await SupaDB.getAllSB();
    print(_todoList);

    print('Local DB fetched');

    setState(() {
      _todoList = todos;
    });
    print('$_todoList');
  }

  void chckboxChng(int index) async {
    // Toggle the status locally
    final updatedStatus = !_todoList[index]!.status;

    // Update the local list item
    setState(() {
      _todoList[index]?.status = updatedStatus;
    });

    // Perform the update in Supabase
    final todoId = _todoList[index]?.title;
    if (todoId != null) {
      final response = await Supabase.instance.client.from('todoTable').update(
              {'status': updatedStatus ? 1 : 0}) // Use 1 for true, 0 for false
          .eq('title', todoId);

      if (response.error != null) {
        print("Failed to update status: ${response.error!.message}");
      } else {
        print("Successfully updated status for Todo ID: $todoId");
      }
    }
  }

  void _addTodo(Todo newTodo) async {
    await AppDB.instnc.addTodo(newTodo);
    _fetchTask(); // Refresh the todo list after adding a new one
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Todo added successfully!',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.amberAccent,
      ),
    );
  }

  void _onTodoDeleted(int id) {
    setState(() {
      _todoList.removeWhere((todo) => todo?.id == id);
    });
  }

  void _deleteTodo(int? id) async {
    if (id != null) {
      await AppDB.instnc.deleteTodoById(id);
      _onTodoDeleted(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Todo deleted successfully!',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.amberAccent,
        ),
      );
    }
  }

  void _onTodoUpdated(Todo todo) {
    setState(() {
      // Replace the updated todo in the list
      int index = _todoList.indexWhere((t) => t?.id == todo.id);
      if (index != -1) {
        _todoList[index] = todo;
      }
    });
  }

  void _navigateToAddTodoForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddTodoScreen(onTodoAdded: _addTodo)),
    );
  }

  void deletefrmSB(int? id) async {
    if (id != null) {
      await SupaDB.deleteSB(id);
      //_onTodoDeleted(id);
    }
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
        title: const Text(
          'To-Do',
        ),
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
                image: Image.asset(
                  'assets/bg3.png',
                ).image,
              ),
            ),
            child: Center(
              child: _todoList.isEmpty
                  // If list is empty, display this text
                  ? const Text(
                      'The list is empty!',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white10),
                    )
                  // Otherwise display the list
                  : ListView.builder(
                      itemCount: _todoList.length,
                      physics: const ScrollPhysics(),
                      itemBuilder: (BuildContext context, index) {
                        return Card(
                          margin: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
                          child: GestureDetector(
                            onLongPress: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EditTodoScreen(
                                    todo: _todoList[
                                        index]!, // Pass the todo to edit
                                    onTodoUpdated:
                                        _onTodoUpdated, // Callback for updating the list
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              title: toDolist(
                                taskName: _todoList[index]?.title ?? '',
                                taskCompleted: _todoList[index]?.status == true,
                                onChanged: (value) => chckboxChng(index),
                                taskDetail: _todoList[index]?.details ?? '',
                              ),
                              subtitle: Text(_todoList[index]?.user ?? ''),
                              trailing: IconButton(
                                  onPressed: () {
                                    deletefrmSB(_todoList[index]?.id);
                                    _deleteTodo(_todoList[index]?.id);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  )),
                            ),
                          ),
                        );
                      },
                    ),
            )),
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
