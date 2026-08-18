import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  int get weight {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
    }
  }

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

enum TaskSyncStatus {
  synced,
  pendingCreate,
  pendingUpdate,
  pendingDelete;

  static TaskSyncStatus fromString(String value) {
    return TaskSyncStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => TaskSyncStatus.synced,
    );
  }
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.isCompleted,
    required this.createdDate,
    this.updatedDate,
    this.syncStatus = TaskSyncStatus.synced,
  });

  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdDate;
  final DateTime? updatedDate;
  final TaskSyncStatus syncStatus;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdDate,
    DateTime? updatedDate,
    TaskSyncStatus? syncStatus,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'createdDate': Timestamp.fromDate(createdDate),
      'updatedDate': updatedDate == null
          ? null
          : Timestamp.fromDate(updatedDate!),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: TaskPriority.fromString(
        json['priority'] as String? ?? 'medium',
      ),
      dueDate: _dateFromJson(json['dueDate']) ?? DateTime.now(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdDate: _dateFromJson(json['createdDate']) ?? DateTime.now(),
      updatedDate: _dateFromJson(json['updatedDate']),
    );
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate?.toIso8601String(),
      'syncStatus': syncStatus.name,
    };
  }

  factory Task.fromLocalMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      priority: TaskPriority.fromString(map['priority'] as String? ?? 'medium'),
      dueDate: DateTime.parse(map['dueDate'] as String),
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      createdDate: DateTime.parse(map['createdDate'] as String),
      updatedDate: map['updatedDate'] == null
          ? null
          : DateTime.parse(map['updatedDate'] as String),
      syncStatus: TaskSyncStatus.fromString(
        map['syncStatus'] as String? ?? TaskSyncStatus.synced.name,
      ),
    );
  }

  static DateTime? _dateFromJson(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
