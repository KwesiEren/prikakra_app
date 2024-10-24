import 'package:flutter/material.dart';

import '../models/db_provider.dart';
import '../models/task.dart';
import '../models/task_type.dart';

class EditTodoScreen extends StatefulWidget {
  final Todo todo;
  final Function(Todo) onTodoUpdated;

  const EditTodoScreen({
    Key? key,
    required this.todo,
    required this.onTodoUpdated,
  }) : super(key: key);

  @override
  _EditTodoScreenState createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String? _details;
  late TaskType _taskType;
  bool _status = false;

  @override
  void initState() {
    super.initState();
    _title = widget.todo.title;
    _details = widget.todo.details;
    _taskType = widget.todo.taskType;
    _status = widget.todo.status;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedTodo = widget.todo.copyWith(
        title: _title,
        details: _details,
        taskType: _taskType,
        status: _status,
      );

      await AppDB.instnc.updateTodo(updatedTodo);
      widget.onTodoUpdated(updatedTodo);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todo updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Todo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value!,
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
              ),
              TextFormField(
                initialValue: _details,
                decoration: InputDecoration(labelText: 'Details'),
                onSaved: (value) => _details = value,
              ),
              DropdownButtonFormField<TaskType>(
                decoration: InputDecoration(labelText: 'Task Type'),
                value: _taskType,
                onChanged: (value) {
                  setState(() {
                    _taskType = value!;
                  });
                },
                items: TaskType.values.map((TaskType type) {
                  return DropdownMenuItem<TaskType>(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),
              ),
              SwitchListTile(
                title: Text('Status'),
                value: _status,
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Update Todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
