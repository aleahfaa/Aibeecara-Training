import '../models/todo_model.dart';
import 'package:hive/hive.dart';

class TodoRepository {
  Future<List<Todo>> getTodos() async {
    final box = Hive.box<Todo>('todos');
    return box.values.toList();
  }

  Future<void> addTodo(Todo todo) async {
    final box = Hive.box<Todo>('todos');
    await box.add(todo);
  }

  Future<void> updateTodo(int index, Todo todo) async {
    final box = Hive.box<Todo>('todos');
    await box.putAt(index, todo);
  }

  Future<void> deleteTodo(int index) async {
    final box = Hive.box<Todo>('todos');
    await box.deleteAt(index);
  }
}
