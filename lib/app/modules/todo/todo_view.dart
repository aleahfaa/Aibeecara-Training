import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/todo_controller.dart';
import '../../data/models/todo_model.dart';
import '../../routes/app_pages.dart';
import 'add_todo_view.dart';

class TodoView extends GetView<TodoController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        centerTitle: true,
        actions: [
          Obx(() {
            final hasCompletedTasks = controller.todos.any(
              (todo) => todo.isCompleted,
            );
            if (!hasCompletedTasks) return SizedBox.shrink();
            return IconButton(
              icon: Icon(Icons.cleaning_services),
              tooltip: 'Delete All Completed Tasks',
              onPressed: () {
                Get.defaultDialog(
                  title: 'Delete Completed Tasks',
                  middleText:
                      'Are you sure you want to delete all completed tasks?',
                  textConfirm: 'Delete',
                  textCancel: 'Cancel',
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    controller.deleteCompletedTodos();
                    Get.back();
                  },
                );
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.todos.isEmpty) {
          return Center(child: Text('No tasks yet. Add your first task!'));
        }
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.groupedTodos.length,
          itemBuilder: (context, index) {
            final dateKey = controller.groupedTodos.keys.elementAt(index);
            final todos = controller.groupedTodos[dateKey]!;
            if (todos.isEmpty) {
              return SizedBox.shrink();
            }
            String formattedDate;
            if (dateKey == 'No Date') {
              formattedDate = 'No Due Date';
            } else {
              final dateParts = dateKey.split('-');
              final date = DateTime(
                int.parse(dateParts[0]),
                int.parse(dateParts[1]),
                int.parse(dateParts[2]),
              );
              formattedDate = DateFormat.yMMMMd().format(date);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: todos.length,
                  itemBuilder: (context, todoIndex) {
                    final todo = todos[todoIndex];
                    final originalIndex = controller.todos.indexWhere(
                      (t) => t.id == todo.id,
                    );
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Dismissible(
                        key: Key(todo.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed:
                            (_) => controller.deleteTodo(originalIndex),
                        child: ExpansionTile(
                          leading: Checkbox(
                            value: todo.isCompleted,
                            onChanged:
                                (_) => controller.toggleTodoStatus(
                                  originalIndex,
                                  todo,
                                ),
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration:
                                  todo.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                              color: todo.isCompleted ? Colors.grey : null,
                            ),
                          ),
                          subtitle:
                              todo.dueTime != null
                                  ? Text(
                                    'Due: ${DateFormat.jm().format(todo.dueTime!)}',
                                    style: TextStyle(
                                      color:
                                          todo.isCompleted
                                              ? Colors.grey
                                              : Colors.red,
                                    ),
                                  )
                                  : null,
                          children: [
                            if (todo.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(todo.description),
                                ),
                              ),
                            if (todo.subTasks.isNotEmpty) ...[
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Subtasks:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: todo.subTasks.length,
                                itemBuilder: (context, subTaskIndex) {
                                  final subTask = todo.subTasks[subTaskIndex];
                                  return ListTile(
                                    leading: Checkbox(
                                      value: subTask.isCompleted,
                                      onChanged:
                                          (_) => controller.toggleSubTaskStatus(
                                            originalIndex,
                                            todo,
                                            subTaskIndex,
                                          ),
                                    ),
                                    title: Text(
                                      subTask.title,
                                      style: TextStyle(
                                        decoration:
                                            subTask.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                        color:
                                            subTask.isCompleted
                                                ? Colors.grey
                                                : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                            ButtonBar(
                              children: [
                                TextButton.icon(
                                  icon: Icon(Icons.edit),
                                  label: Text('Edit'),
                                  onPressed:
                                      () => _editTodo(
                                        context,
                                        originalIndex,
                                        todo,
                                      ),
                                ),
                                TextButton.icon(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  label: Text('Delete'),
                                  onPressed: () {
                                    Get.defaultDialog(
                                      title: 'Delete Task',
                                      middleText:
                                          'Are you sure you want to delete this task?',
                                      textConfirm: 'Delete',
                                      textCancel: 'Cancel',
                                      confirmTextColor: Colors.white,
                                      onConfirm: () {
                                        controller.deleteTodo(originalIndex);
                                        Get.back();
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addTodo(context),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAllNamed(Routes.HOME);
              Get.find<HomeController>().refreshTasks();
              break;
            case 1:
              Get.offAndToNamed(Routes.FAVORITES);
              break;
            case 2:
              break;
            case 3:
              Get.offAndToNamed(Routes.NOTES);
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'To-Do'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
        ],
      ),
    );
  }

  void _addTodo(BuildContext context) {
    Get.to(() => AddTodoView());
  }

  void _editTodo(BuildContext context, int index, Todo todo) {
    Get.to(() => AddTodoView(todoToEdit: todo, todoIndex: index));
  }
}
