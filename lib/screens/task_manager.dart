import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/add_task_dialog.dart';

class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  final List<Task> _tasks = [];

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
  }

  void _editTask(int index, Task updatedTask) {
    setState(() {
      _tasks[index] = updatedTask;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddTaskDialog(onAddTask: _addTask);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Task Manager'),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Text(task.description),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}