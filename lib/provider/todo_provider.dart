import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_simple/repo/todo_repo.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final todoRepositoryProvider = Provider<ITodoRepository>((ref) {
  return FirebaseTodoRepository(ref.watch(firestoreProvider));
});
