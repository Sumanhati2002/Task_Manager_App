import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/task.dart';
import 'task_services.dart';

class LocalTaskService implements LocalTaskDataSource {
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'task_manager.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            priority TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            isCompleted INTEGER NOT NULL,
            createdDate TEXT NOT NULL,
            updatedDate TEXT,
            syncStatus TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  @override
  Future<List<Task>> getTasks({bool includeDeleted = false}) async {
    final db = await _db;
    final rows = await db.query(
      'tasks',
      where: includeDeleted ? null : 'syncStatus != ?',
      whereArgs: includeDeleted ? null : [TaskSyncStatus.pendingDelete.name],
      orderBy: 'createdDate DESC',
    );
    return rows.map(Task.fromLocalMap).toList();
  }

  @override
  Future<List<Task>> getPendingTasks() async {
    final db = await _db;
    final rows = await db.query(
      'tasks',
      where: 'syncStatus != ?',
      whereArgs: [TaskSyncStatus.synced.name],
    );
    return rows.map(Task.fromLocalMap).toList();
  }

  @override
  Future<void> upsertTask(Task task) async {
    final db = await _db;
    await db.insert(
      'tasks',
      task.toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsertTasks(List<Task> tasks) async {
    final db = await _db;
    final batch = db.batch();
    for (final task in tasks) {
      batch.insert(
        'tasks',
        task.toLocalMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> markForDelete(String id) async {
    final db = await _db;
    await db.update(
      'tasks',
      {'syncStatus': TaskSyncStatus.pendingDelete.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    final db = await _db;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
