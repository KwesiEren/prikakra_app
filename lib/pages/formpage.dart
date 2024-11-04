import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task.dart';
import '../models/task_type.dart';

class AddTodoScreen extends StatefulWidget {
  final Function(Todo) onTodoAdded;

  const AddTodoScreen({required this.onTodoAdded});

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

// This is the codes for the Form page when
// you want to create a new task.

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String? _details;
  TaskType _taskType = TaskType.today;
  String _user = '';
  String? _team;
  bool _status = false; // Changed to non-final
  bool _isSynced = false; // Changed to non-final

// This Adds the new task to the online DB
  Future<void> addtoSB(Todo todo) async {
    await Supabase.instance.client.from('todoTable').insert(todo.toJson());
    print('Todo uploaded to Supabase');
  }

  // This is the Function to be called when you
  // press the "Add task" button. This handles
  // adding the task to the local database and
  // pushing it to the online database.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newTodo = Todo(
        title: _title,
        details: _details,
        user: _user,
        team: _team,
        taskType: _taskType,
        crtedDate: DateTime.now(),
        status: _status,
        isSynced: _isSynced,
      );

      addtoSB(newTodo);

      widget.onTodoAdded(newTodo);
      Navigator.pop(context); // Go back after submission
    }
    // Honestly I think a better function can be made to tackle this sort of operation but
    // for now I will work with this.
  }

  // UI code block here:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Details'),
                maxLines: 4,
                onSaved: (value) {
                  _details = value;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<TaskType>(
                value: _taskType,
                decoration: const InputDecoration(labelText: 'Task Type'),
                items: TaskType.values.map((taskType) {
                  return DropdownMenuItem<TaskType>(
                    value: taskType,
                    child: Text(taskType.name),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _taskType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'User'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a user';
                  }
                  return null;
                },
                onSaved: (value) {
                  _user = value!;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Team'),
                onSaved: (value) {
                  _team = value;
                },
              ),
              const SizedBox(height: 10),
              /* SwitchListTile(
                title: const Text('Status'),
                value: _status,
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
              ),*/
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
