import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../model/task.dart';
import 'task_services.dart';

class FirestoreTaskService implements RemoteTaskDataSource {
  FirestoreTaskService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestoreOrThrow.collection('tasks');

  FirebaseFirestore get _firestoreOrThrow {
    if (_firestore != null) return _firestore;
    if (Firebase.apps.isEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-configured',
        message: 'Firebase has not been initialized.',
      );
    }
    return FirebaseFirestore.instance;
  }

  @override
  Future<List<Task>> fetchTasks() async {
    final snapshot = await _collection
        .orderBy('createdDate', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Task.fromJson({...data, 'id': data['id'] ?? doc.id});
    }).toList();
  }

  @override
  Future<void> upsertTask(Task task) async {
    await _collection.doc(task.id).set(task.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteTask(String id) async {
    await _collection.doc(id).delete();
  }
}
