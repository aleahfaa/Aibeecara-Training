import 'package:hive/hive.dart';
part 'todo_model.g.dart';

@HiveType(typeId: 1)
class Todo {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String description;
  @HiveField(3)
  DateTime? dueDate;
  @HiveField(4)
  DateTime? dueTime;
  @HiveField(5)
  List<SubTask> subTasks;
  @HiveField(6)
  bool isCompleted;
  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.dueTime,
    List<SubTask>? subTasks,
    this.isCompleted = false,
  }) : this.subTasks = subTasks ?? [];
}

@HiveType(typeId: 2)
class SubTask {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  bool isCompleted;
  SubTask({required this.id, required this.title, this.isCompleted = false});
}
