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

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      isCompleted: json['isCompleted'],
    );
  }
}