import '../model/task.dart';

abstract class LocalTaskDataSource {
  Future<List<Task>> getTasks({bool includeDeleted = false});
  Future<List<Task>> getPendingTasks();
  Future<void> upsertTask(Task task);
  Future<void> upsertTasks(List<Task> tasks);
  Future<void> markForDelete(String id);
  Future<void> deleteTask(String id);
}

abstract class RemoteTaskDataSource {
  Future<List<Task>> fetchTasks();
  Future<void> upsertTask(Task task);
  Future<void> deleteTask(String id);
}

abstract class NetworkStatusService {
  Stream<bool> get onlineStatus;
  Future<bool> get isOnline;
}
