class TodoModel {
  int id;
  String task;
  String source;
  DateTime creat_date;
  String? team;

  TodoModel(
      {required this.id,
      required this.task,
      required this.source,
      required this.creat_date,
      this.team});

  Map<String, dynamic> toMap() {
    return ({
      "id": id,
      "task": task,
      "source": source,
      "team": team ?? "Unassigned",
      "creat_date": creat_date
    });
  }
}
