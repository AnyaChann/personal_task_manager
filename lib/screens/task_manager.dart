import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../widgets/add_task_dialog.dart';

class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  final List<Task> _tasks = [];
  String _filter = 'All'; // Bộ lọc: 'All', 'Completed', 'Incomplete'

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load tasks from local storage
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> tasksList = jsonDecode(tasksJson);
      setState(() {
        _tasks.clear();
        _tasks.addAll(tasksList.map((task) => Task.fromJson(task)));
      });
    }
  }

  // Save tasks to local storage
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
    _saveTasks();
  }

  void _editTask(int index, Task updatedTask) {
    setState(() {
      _tasks[index] = updatedTask;
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
    _saveTasks();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddTaskDialog(onAddTask: _addTask);
      },
    );
  }

  List<Task> _getFilteredTasks() {
    List<Task> filteredTasks = _tasks;

    // Lọc theo trạng thái
    if (_filter == 'Completed') {
      filteredTasks = _tasks.where((task) => task.isCompleted).toList();
    } else if (_filter == 'Incomplete') {
      filteredTasks = _tasks.where((task) => !task.isCompleted).toList();
    }

    // Sắp xếp theo deadline
    filteredTasks.sort((a, b) => a.deadline.compareTo(b.deadline));

    return filteredTasks;
  }

  int _getCompletedTaskCount() {
    return _tasks.where((task) => task.isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();
    final totalTasks = _tasks.length;
    final completedTasks = _getCompletedTaskCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Task Manager'),
        actions: [
          DropdownButton<String>(
            value: _filter,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _filter = value;
                });
              }
            },
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Completed', child: Text('Completed')),
              DropdownMenuItem(value: 'Incomplete', child: Text('Incomplete')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Thống kê tổng số công việc và số đã hoàn thành
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Tasks: $totalTasks',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Completed: $completedTasks',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),
          // Danh sách công việc
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return Container(
                  color: _getTaskColor(task).withOpacity(0.1), // Màu nền nhạt
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                      'Deadline: ${task.deadline}',
                      style: TextStyle(
                        color: _getTaskColor(task), // Màu chữ theo trạng thái
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                          ),
                          onPressed: () => _toggleTaskCompletion(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AddTaskDialog(
                                  task: task,
                                  onAddTask: (updatedTask) => _editTask(index, updatedTask),
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTask(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getTaskColor(Task task) {
    final now = DateTime.now();
    final difference = task.deadline.difference(now).inHours;

    if (task.isCompleted) {
      return Colors.green; // Công việc đã hoàn thành
    } else if (difference <= 24) {
      return Colors.red; // Công việc sắp hết hạn (trong vòng 24 giờ)
    } else if (difference <= 72) {
      return Colors.orange; // Công việc sắp đến hạn (trong vòng 3 ngày)
    } else {
      return Colors.blue; // Công việc còn nhiều thời gian
    }
  }
}