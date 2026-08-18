import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../model/task.dart';
import '../model/task_filter.dart';
import '../repo/task_repository_contract.dart';

class TaskViewModel extends ChangeNotifier {
  TaskViewModel({required TaskRepositoryContract repository})
    : _repository = repository {
    _connectivitySubscription = _repository.onlineStatus.listen((online) {
      _isOnline = online;
      notifyListeners();
      if (online) syncNow();
    });
  }

  final TaskRepositoryContract _repository;
  final _uuid = const Uuid();

  StreamSubscription<bool>? _connectivitySubscription;
  List<Task> _tasks = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  bool _isOnline = true;
  String? _errorMessage;
  String _searchQuery = '';
  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.dueDate;
  ThemeMode _themeMode = ThemeMode.light;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  TaskFilter get filter => _filter;
  TaskSort get sort => _sort;
  ThemeMode get themeMode => _themeMode;

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  List<Task> get visibleTasks {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = _tasks.where((task) {
      final matchesSearch =
          query.isEmpty || task.title.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.completed => task.isCompleted,
        TaskFilter.pending => !task.isCompleted,
      };
      return matchesSearch && matchesFilter;
    }).toList();

    filtered.sort((a, b) {
      switch (_sort) {
        case TaskSort.dueDate:
          return a.dueDate.compareTo(b.dueDate);
        case TaskSort.priority:
          return b.priority.weight.compareTo(a.priority.weight);
      }
    });
    return filtered;
  }

  int get pendingSyncCount {
    return _tasks
        .where((task) => task.syncStatus != TaskSyncStatus.synced)
        .length;
  }

  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      _tasks = await _repository.loadTasks();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Could not load remote tasks. ${_formatSyncError(error)}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      dueDate: dueDate,
      isCompleted: false,
      createdDate: now,
      updatedDate: now,
    );
    await _runMutation(() => _repository.createTask(task));
  }

  Future<void> updateTask(Task task) async {
    await _runMutation(
      () => _repository.updateTask(task.copyWith(updatedDate: DateTime.now())),
    );
  }

  Future<void> toggleCompletion(Task task) async {
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<void> deleteTask(Task task) async {
    await _runMutation(() => _repository.deleteTask(task));
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();
    try {
      await _repository.syncPendingChanges();
      _tasks = await _repository.loadTasks();
      _errorMessage = null;
    } catch (error) {
      _errorMessage =
          'Sync paused. ${_formatSyncError(error)} Changes are saved locally.';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void updateSort(TaskSort sort) {
    _sort = sort;
    notifyListeners();
  }

  Future<void> _runMutation(Future<void> Function() mutation) async {
    try {
      await mutation();
      _tasks = await _repository.loadTasks();
      _errorMessage = null;
    } catch (error) {
      _tasks = await _repository.loadTasks();
      _errorMessage =
          'Saved locally. ${_formatSyncError(error)} Remote sync will retry.';
    } finally {
      notifyListeners();
    }
  }

  String _formatSyncError(Object error) {
    if (error is FirebaseException) {
      return '[${error.code}] ${error.message ?? 'Firebase request failed.'}';
    }
    return error.toString();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
