import 'package:flutter/material.dart';

import '../components/todo_list.dart';
import '../models/db_provider.dart';
import '../models/task.dart';

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
    setState(() {
      _todoList = todos;
    });
  }

  void chckboxChng(int index) {
    setState(() {
      _todoList[index]?.status = !_todoList[index]!.status;
    });
  }

  void _addTodo(Todo newTodo) async {
    await AppDB.instnc.addTodo(newTodo);
    _fetchTodos(); // Refresh the todo list after adding a new one
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Todo added successfully!')),
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
        SnackBar(content: Text('Todo deleted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To-Do',
        ),
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
                              Navigator.pushNamed(context, '/editform');
                            },
                            child: ListTile(
                              title: toDolist(
                                taskName: _todoList[index]?.title ?? '',
                                taskCompleted:
                                    _todoList[index]?.status == false,
                                onChanged: (value) => chckboxChng(index),
                                taskDetail: _todoList[index]?.details ?? '',
                              ),
                              subtitle: Text(_todoList[index]?.user ?? ''),
                              trailing: IconButton(
                                  onPressed: () {
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
        onPressed: () {
          Navigator.pushNamed(context, '/formpage');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
