import 'package:todo_simple/model/role.dart';
import 'package:todo_simple/model/todo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ITodoRepository {
  Future<void> createTask(Task todo);
  Future<void> updateTask(Task todo);
  Future<void> deleteTask(String taskId);
  Stream<List<Task>> fetchTasks(String currentUserId, UserRole role);
}

class FirebaseTodoRepository implements ITodoRepository {
  final FirebaseFirestore firestore;

  FirebaseTodoRepository(this.firestore);

  @override
  Future<void> createTask(Task todo) async {
    final docRef = firestore.collection('todos').doc();
    await docRef.set(todo.copyWith(id: docRef.id).toJson());
  }

  @override
  Future<void> updateTask(Task todo) async {
    await firestore.collection('todos').doc(todo.id).update(todo.toJson());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await firestore.collection('todos').doc(taskId).delete();
  }

  @override
  Stream<List<Task>> fetchTasks(String currentUserId, UserRole role) {
    final query = role == UserRole.manager
        ? firestore.collection('todos').orderBy("createdAt", descending: true)
        : firestore
              .collection('todos')
              .orderBy("createdAt", descending: true)
              .where(
                Filter.or(
                  Filter("assignedTo", isEqualTo: currentUserId),
                  Filter("assignedTo", isNull: true),
                ),
              );

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Task.fromDoc(doc)).toList(),
    );
  }
}
