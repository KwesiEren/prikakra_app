import 'package:firebase_test2/models/db_provider.dart';
import 'package:flutter/material.dart';

class TaskDisp extends StatefulWidget {
  const TaskDisp({super.key});

  @override
  State<TaskDisp> createState() => _TaskDispState();
}

class _TaskDispState extends State<TaskDisp> {
  List<Map<String, dynamic>> taskList = [];

  bool _isLoading = true;

  void _refreshList() async {
    final data = await DBprovider.callAll();
    setState(() {
      taskList = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshList();
    print(" Total number of task to do is ${taskList.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
