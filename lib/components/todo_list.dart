import 'package:flutter/material.dart';

class toDolist extends StatefulWidget {
  const toDolist(
      {super.key,
      required this.taskName,
      required this.taskCompleted,
      required this.onChanged,
      required this.taskDetail
      //required this.deleteFunction,
      });

  final String taskName;
  final String taskDetail;
  final bool taskCompleted;
  final Function(bool?)? onChanged;

  @override
  State<toDolist> createState() => _toDolistState();
}

class _toDolistState extends State<toDolist> {
  @override
  Widget build(BuildContext context) {
    bool expands = false;
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 0,
        right: 0,
        bottom: 20,
      ),
      child: GestureDetector(
        child: Row(
          children: [
            Checkbox(
              value: widget.taskCompleted,
              onChanged: widget.onChanged,
              side: const BorderSide(color: Colors.black),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 185),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.taskName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            decoration: widget.taskCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationThickness: 3,
                            decorationColor: Colors.black),
                      ),
                      ExpandIcon(
                        isExpanded: expands,
                        color: Colors.black,
                        expandedColor: Colors.white,
                        onPressed: (bool isExpanded) {
                          setState(() {
                            expands = !isExpanded;
                          });
                        },
                      ),
                    ],
                  ),
                  if (expands)
                    Container(
                      child: Text(widget.taskDetail,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          )),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
