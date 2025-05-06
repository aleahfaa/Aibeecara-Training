import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/todo_controller.dart';
import '../../data/models/todo_model.dart';

class AddTodoView extends StatefulWidget {
  final Todo? todoToEdit;
  final int? todoIndex;
  const AddTodoView({Key? key, this.todoToEdit, this.todoIndex})
    : super(key: key);
  @override
  _AddTodoViewState createState() => _AddTodoViewState();
}

class _AddTodoViewState extends State<AddTodoView> {
  final TodoController controller = Get.find<TodoController>();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<SubTask> _subTasks = [];
  @override
  void initState() {
    super.initState();
    if (widget.todoToEdit != null) {
      _titleController.text = widget.todoToEdit!.title;
      _descriptionController.text = widget.todoToEdit!.description;
      _selectedDate = widget.todoToEdit!.dueDate;
      _selectedTime =
          widget.todoToEdit!.dueTime != null
              ? TimeOfDay.fromDateTime(widget.todoToEdit!.dueTime!)
              : null;
      _subTasks = List.from(widget.todoToEdit!.subTasks);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addSubTask() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add Subtask'),
            content: TextField(
              controller: textController,
              decoration: InputDecoration(hintText: 'Enter subtask'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Add'),
                onPressed: () {
                  if (textController.text.trim().isNotEmpty) {
                    setState(() {
                      _subTasks.add(
                        SubTask(
                          id: Uuid().v4(),
                          title: textController.text.trim(),
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
    );
  }

  void _removeSubTask(int index) {
    setState(() {
      _subTasks.removeAt(index);
    });
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      DateTime? dueTime;
      if (_selectedDate != null && _selectedTime != null) {
        dueTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }
      if (widget.todoToEdit != null && widget.todoIndex != null) {
        widget.todoToEdit!.title = _titleController.text.trim();
        widget.todoToEdit!.description = _descriptionController.text.trim();
        widget.todoToEdit!.dueDate = _selectedDate;
        widget.todoToEdit!.dueTime = dueTime;
        widget.todoToEdit!.subTasks = _subTasks;
        controller.updateTodo(widget.todoIndex!, widget.todoToEdit!);
      } else {
        controller.addTodo(
          _titleController.text.trim(),
          _descriptionController.text.trim(),
          _selectedDate,
          dueTime,
          _subTasks,
        );
      }
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todoToEdit != null ? 'Edit Task' : 'Add Task'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              Text(
                'Due Date & Time (Optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.calendar_today),
                      label: Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      ),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.access_time),
                      label: Text(
                        _selectedTime == null
                            ? 'Select Time'
                            : '${_selectedTime!.format(context)}',
                      ),
                      onPressed: () => _selectTime(context),
                    ),
                  ),
                ],
              ),
              if (_selectedDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton.icon(
                    icon: Icon(Icons.clear),
                    label: Text('Clear Date & Time'),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                        _selectedTime = null;
                      });
                    },
                  ),
                ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtasks (Optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addSubTask,
                    tooltip: 'Add Subtask',
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (_subTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'No subtasks added',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _subTasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_subTasks[index].title),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeSubTask(index),
                    ),
                  );
                },
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      widget.todoToEdit != null ? 'Update Task' : 'Save Task',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  onPressed: _saveTodo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
