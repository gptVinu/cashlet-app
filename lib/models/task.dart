import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }

enum TaskRepeatCycle { none, daily, weekly, monthly }

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final bool isCompleted;
  final TaskPriority priority;
  final TaskRepeatCycle repeatCycle;
  final DateTime? reminderTime;

  Task({
    String? id,
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.repeatCycle = TaskRepeatCycle.none,
    this.reminderTime,
  }) : id = id ?? const Uuid().v4();

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    TaskPriority? priority,
    TaskRepeatCycle? repeatCycle,
    DateTime? reminderTime,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      repeatCycle: repeatCycle ?? this.repeatCycle,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority.index,
      'repeatCycle': repeatCycle.index,
      'reminderTime': reminderTime?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
      priority: TaskPriority.values[json['priority']],
      repeatCycle: TaskRepeatCycle.values[json['repeatCycle']],
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'])
          : null,
    );
  }
}
