import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thư viện để định dạng ngày và giờ
import '../models/task.dart';

class AddTaskDialog extends StatefulWidget {
  final Task? task;
  final Function(Task) onAddTask;

  const AddTaskDialog({super.key, this.task, required this.onAddTask});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDeadline = widget.task!.deadline;
    }
  }

  void _submit() {
    if (_titleController.text.isEmpty || _selectedDeadline == null) return;

    final newTask = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      deadline: _selectedDeadline!,
    );

    widget.onAddTask(newTask);
    Navigator.of(context).pop();
  }

  Future<void> _pickDateTime() async {
    // Chọn ngày
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Chọn giờ và phút
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDeadline ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _pickDateTime,
              child: Text(
                _selectedDeadline == null
                    ? 'Pick a Deadline'
                    : 'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDeadline!)}',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}