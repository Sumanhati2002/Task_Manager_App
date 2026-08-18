enum TaskFilter {
  all,
  completed,
  pending;

  String get label {
    switch (this) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.pending:
        return 'Pending';
    }
  }
}

enum TaskSort {
  dueDate,
  priority;

  String get label {
    switch (this) {
      case TaskSort.dueDate:
        return 'Due date';
      case TaskSort.priority:
        return 'Priority';
    }
  }
}
