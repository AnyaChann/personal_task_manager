class Task {
  String title;
  String description;
  DateTime deadline;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.deadline,
    this.isCompleted = false,
  });
}