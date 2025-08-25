import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_simple/model/todo.dart';
import 'package:todo_simple/repo/todo_repo.dart';
import '../model/role.dart';
import 'auth.dart'; // <-- for authStateProvider

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final todoRepositoryProvider = Provider<ITodoRepository>((ref) {
  return FirebaseTodoRepository(ref.watch(firestoreProvider));
});

class TodoNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final ITodoRepository repository;
  final String currentUserId;
  final UserRole role;
  StreamSubscription? _subscription;

  TodoNotifier(this.repository, this.currentUserId, this.role)
    : super(const AsyncValue.loading()) {
    _listenToTodos();
  }

  void _listenToTodos() {
    _subscription = repository
        .fetchTasks(currentUserId, role)
        .listen(
          (tasks) {
            state = AsyncValue.data(tasks);
          },
          onError: (e, st) {
            state = AsyncValue.error(e, st);
          },
        );
  }

  Future<void> addTask(Task todo) async {
    await repository.createTask(todo);
  }

  Future<void> updateTask(Task todo) async {
    await repository.updateTask(todo);
  }

  Future<void> deleteTask(String id) async {
    await repository.deleteTask(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Dynamically provides tasks for the logged-in user
final todoProvider =
    StateNotifierProvider<TodoNotifier, AsyncValue<List<Task>>>((ref) {
      final authState = ref.watch(authStateProvider).value; // current AppUser?

      if (authState == null) {
        // user not logged in
        return TodoNotifier(
          ref.watch(todoRepositoryProvider),
          "", // no UID
          UserRole.employee,
        );
      }

      return TodoNotifier(
        ref.watch(todoRepositoryProvider),
        authState.uid,
        authState.role,
      );
    });
