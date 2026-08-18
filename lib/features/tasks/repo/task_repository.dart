import '../model/task.dart';
import '../service/task_services.dart';
import 'task_repository_contract.dart';

class TaskRepository implements TaskRepositoryContract {
  TaskRepository({
    required LocalTaskDataSource localService,
    required RemoteTaskDataSource remoteService,
    required NetworkStatusService connectivityService,
  }) : _localService = localService,
       _remoteService = remoteService,
       _connectivityService = connectivityService;

  final LocalTaskDataSource _localService;
  final RemoteTaskDataSource _remoteService;
  final NetworkStatusService _connectivityService;

  @override
  Stream<bool> get onlineStatus => _connectivityService.onlineStatus;

  @override
  Future<List<Task>> loadTasks() async {
    final localTasks = await _localService.getTasks();
    if (!await _connectivityService.isOnline) return localTasks;

    try {
      await syncPendingChanges();
      final remoteTasks = await _remoteService.fetchTasks();
      await _localService.upsertTasks(
        remoteTasks
            .map((task) => task.copyWith(syncStatus: TaskSyncStatus.synced))
            .toList(),
      );
      return _localService.getTasks();
    } catch (_) {
      return localTasks;
    }
  }

  @override
  Future<void> createTask(Task task) async {
    final shouldSyncNow = await _connectivityService.isOnline;
    final localTask = task.copyWith(
      syncStatus: shouldSyncNow
          ? TaskSyncStatus.synced
          : TaskSyncStatus.pendingCreate,
    );
    await _localService.upsertTask(localTask);

    if (!shouldSyncNow) return;
    try {
      await _remoteService.upsertTask(task);
    } catch (_) {
      await _localService.upsertTask(
        task.copyWith(syncStatus: TaskSyncStatus.pendingCreate),
      );
      rethrow;
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    final shouldSyncNow = await _connectivityService.isOnline;
    final existingStatus = task.syncStatus;
    final pendingStatus = existingStatus == TaskSyncStatus.pendingCreate
        ? TaskSyncStatus.pendingCreate
        : TaskSyncStatus.pendingUpdate;
    await _localService.upsertTask(
      task.copyWith(
        syncStatus: shouldSyncNow ? TaskSyncStatus.synced : pendingStatus,
      ),
    );

    if (!shouldSyncNow) return;
    try {
      await _remoteService.upsertTask(task);
    } catch (_) {
      await _localService.upsertTask(task.copyWith(syncStatus: pendingStatus));
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(Task task) async {
    final shouldSyncNow = await _connectivityService.isOnline;
    if (shouldSyncNow || task.syncStatus == TaskSyncStatus.pendingCreate) {
      await _localService.deleteTask(task.id);
    } else {
      await _localService.markForDelete(task.id);
    }

    if (!shouldSyncNow || task.syncStatus == TaskSyncStatus.pendingCreate) {
      return;
    }
    try {
      await _remoteService.deleteTask(task.id);
    } catch (_) {
      await _localService.upsertTask(
        task.copyWith(syncStatus: TaskSyncStatus.pendingDelete),
      );
      rethrow;
    }
  }

  @override
  Future<void> syncPendingChanges() async {
    if (!await _connectivityService.isOnline) {
      return;
    }

    final pendingTasks = await _localService.getPendingTasks();
    for (final task in pendingTasks) {
      switch (task.syncStatus) {
        case TaskSyncStatus.pendingCreate:
        case TaskSyncStatus.pendingUpdate:
          await _remoteService.upsertTask(task);
          await _localService.upsertTask(
            task.copyWith(syncStatus: TaskSyncStatus.synced),
          );
        case TaskSyncStatus.pendingDelete:
          await _remoteService.deleteTask(task.id);
          await _localService.deleteTask(task.id);
        case TaskSyncStatus.synced:
          break;
      }
    }
  }
}
