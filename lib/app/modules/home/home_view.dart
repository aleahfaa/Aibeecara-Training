import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/home_controller.dart';
import '../../routes/app_pages.dart';
import '../../data/models/todo_model.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Quote'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchQuote();
            await controller.loadUpcomingTasks();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuoteCard(),
                SizedBox(height: 24),
                _buildUpcomingTasksSection(),
                SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Get.toNamed(Routes.FAVORITES);
              break;
            case 2:
              Get.toNamed(Routes.TODO);
              break;
            case 3:
              Get.toNamed(Routes.NOTES);
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

  Widget _buildQuoteCard() {
    if (controller.currentQuote.value == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text('No quotes available')),
        ),
      );
    }
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.currentQuote.value!.text,
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '- ${controller.currentQuote.value!.author}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                GetBuilder<HomeController>(
                  builder:
                      (_) => IconButton(
                        icon: Icon(
                          controller.isFavorite()
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: controller.isFavorite() ? Colors.red : null,
                        ),
                        onPressed: controller.toggleFavorite,
                      ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.refresh),
                label: Text('Get New Quote'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: controller.fetchQuote,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Tasks',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Obx(() {
          if (controller.upcomingTasks.isEmpty) {
            return _buildNoTasksView();
          } else {
            return _buildTasksList();
          }
        }),
      ],
    );
  }

  Widget _buildNoTasksView() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No upcoming tasks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Add tasks to stay organized',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.add_task),
                  label: Text('Add Task'),
                  onPressed: () => Get.toNamed(Routes.TODO),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.note_add),
                  label: Text('Add Note'),
                  onPressed: () => Get.toNamed(Routes.NOTES),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return Column(
      children: [
        ...controller.upcomingTasks.map((task) => _buildTaskCard(task)),
        SizedBox(height: 12),
        OutlinedButton.icon(
          icon: Icon(Icons.view_list),
          label: Text('View All Tasks'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => Get.toNamed(Routes.TODO),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Todo task) {
    final bool hasDueDate = task.dueDate != null;
    final String dueText =
        hasDueDate ? DateFormat.yMMMd().format(task.dueDate!) : 'No due date';
    final String timeText =
        task.dueTime != null ? DateFormat.jm().format(task.dueTime!) : '';
    final String dueDateText =
        hasDueDate && task.dueTime != null ? '$dueText at $timeText' : dueText;
    String remainingText = '';
    if (hasDueDate) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dueDay = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      final difference = dueDay.difference(today).inDays;
      if (difference < 0) {
        remainingText = 'Overdue';
      } else if (difference == 0) {
        remainingText = 'Due today';
      } else if (difference == 1) {
        remainingText = 'Due tomorrow';
      } else {
        remainingText = 'Due in \$difference days';
      }
    }
    Color cardColor = Colors.white;
    if (hasDueDate) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dueDay = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      final difference = dueDay.difference(today).inDays;
      if (difference < 0) {
        cardColor = Colors.red[50]!;
      } else if (difference == 0) {
        cardColor = Colors.orange[50]!;
      } else if (difference <= 2) {
        cardColor = Colors.yellow[50]!;
      }
    }
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => Get.toNamed(Routes.TODO),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color:
                        hasDueDate
                            ? _getDueDateColor(task.dueDate!)
                            : Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dueDateText,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (hasDueDate)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRemainingBadgeColor(task.dueDate!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        remainingText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = dueDay.difference(today).inDays;
    if (difference < 0) {
      return Colors.red;
    } else if (difference == 0) {
      return Colors.orange;
    } else if (difference <= 2) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  Color _getRemainingBadgeColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = dueDay.difference(today).inDays;
    if (difference < 0) {
      return Colors.red[700]!;
    } else if (difference == 0) {
      return Colors.orange[700]!;
    } else if (difference <= 2) {
      return Colors.amber[700]!;
    } else {
      return Colors.green[700]!;
    }
  }
}
