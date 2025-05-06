import 'package:ens/app/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../data/models/todo_model.dart';
import '../data/repositories/todo_repository.dart';

class TodoController extends GetxController {
  final TodoRepository _todoRepository = TodoRepository();
  final RxList<Todo> todos = <Todo>[].obs;
  final RxMap<String, List<Todo>> groupedTodos = <String, List<Todo>>{}.obs;
  @override
  void onInit() {
    super.onInit();
    loadTodos();
  }

  Future<void> loadTodos() async {
    todos.value = await _todoRepository.getTodos();
    _groupTodos();
  }

  void _groupTodos() {
    Map<String, List<Todo>> grouped = {};
    List<Todo> noDateTasks =
        todos.where((todo) => todo.dueDate == null).toList();
    if (noDateTasks.isNotEmpty) {
      grouped['No Date'] = noDateTasks;
    }
    for (var todo in todos.where((todo) => todo.dueDate != null)) {
      String dateKey =
          '${todo.dueDate!.year}-${todo.dueDate!.month}-${todo.dueDate!.day}';
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(todo);
    }
    grouped.forEach((key, list) {
      list.sort((a, b) {
        if (a.dueTime == null && b.dueTime == null) return 0;
        if (a.dueTime == null) return 1;
        if (b.dueTime == null) return -1;
        return a.dueTime!.compareTo(b.dueTime!);
      });
    });
    List<String> sortedKeys =
        grouped.keys.where((key) => key != 'No Date').toList();
    sortedKeys.sort();
    Map<String, List<Todo>> sortedGrouped = {};
    for (var key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }
    if (grouped.containsKey('No Date')) {
      sortedGrouped['No Date'] = grouped['No Date']!;
    }
    groupedTodos.value = sortedGrouped;
  }

  Future<void> addTodo(
    String title,
    String description,
    DateTime? dueDate,
    DateTime? dueTime,
    List<SubTask> subTasks,
  ) async {
    final todo = Todo(
      id: Uuid().v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      dueTime: dueTime,
      subTasks: subTasks,
    );
    await _todoRepository.addTodo(todo);
    await loadTodos();
  }

  Future<void> updateTodo(int index, Todo todo) async {
    await _todoRepository.updateTodo(index, todo);
    await loadTodos();
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshTasks();
    }
  }

  Future<void> deleteTodo(int index) async {
    await _todoRepository.deleteTodo(index);
    await loadTodos();
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshTasks();
    }
  }

  Future<void> toggleTodoStatus(int index, Todo todo) async {
    todo.isCompleted = !todo.isCompleted;
    await _todoRepository.updateTodo(index, todo);
    await loadTodos();
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshTasks();
    }
  }

  Future<void> toggleSubTaskStatus(
    int todoIndex,
    Todo todo,
    int subTaskIndex,
  ) async {
    todo.subTasks[subTaskIndex].isCompleted =
        !todo.subTasks[subTaskIndex].isCompleted;
    await _todoRepository.updateTodo(todoIndex, todo);
    await loadTodos();
  }

  Future<void> deleteCompletedTodos() async {
    final completedIndices = <int>[];
    for (int i = todos.length - 1; i >= 0; i--) {
      if (todos[i].isCompleted) {
        completedIndices.add(i);
      }
    }
    for (final index in completedIndices) {
      await _todoRepository.deleteTodo(index);
    }
    await loadTodos();
  }
}
