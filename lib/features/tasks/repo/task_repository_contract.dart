import '../model/task.dart';

abstract class TaskRepositoryContract {
  Stream<bool> get onlineStatus;

  Future<List<Task>> loadTasks();
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(Task task);
  Future<void> syncPendingChanges();
}
