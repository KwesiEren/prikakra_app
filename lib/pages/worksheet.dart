import 'package:flutter/material.dart';

import '../components/todo_list.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({super.key});

  @override
  State<WorkArea> createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  final _contrlr = TextEditingController();
  List todoList = [
    ['Code the Front-End.', false],
    ['Code the Back-End.', false],
  ];

  void chckboxChng(int index) {
    setState(() {
      todoList[index][1] = !todoList[index][1];
    });
  }

  void delTask(int index) {
    setState(() {
      todoList.removeAt(index);
    });
  }

  void savenewTask() {
    setState(() {
      todoList.add([_contrlr.text, false]);
      _contrlr.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'To-Do',
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Container(
            width: w,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: Image.asset(
                  'assets/bg01.png',
                ).image,
              ),
            ),
            child: Center(
              child: todoList.isEmpty
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
                      itemCount: todoList.length,
                      physics: const ScrollPhysics(),
                      itemBuilder: (BuildContext context, index) {
                        return Card(
                          margin: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
                          child: ListTile(
                            title: toDolist(
                              taskName: todoList[index][0],
                              taskCompleted: todoList[index][1],
                              onChanged: (value) => chckboxChng(index),
                            ),
                            trailing: IconButton(
                                onPressed: () {
                                  delTask(index);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                )),
                          ),
                        );
                      },
                    ),
            )),
      ),
      floatingActionButton: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                maxLines: 4,
                minLines: 1,
                controller: _contrlr,
                decoration: InputDecoration(
                  hintText: 'Begin Entry Here',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            hoverColor: Colors.greenAccent,
            onPressed: savenewTask,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
