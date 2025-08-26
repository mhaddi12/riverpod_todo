import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_simple/repo/todo_repo.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final todoRepositoryProvider = Provider<ITodoRepository>((ref) {
  return FirebaseTodoRepository(ref.watch(firestoreProvider));
});

/// 🔹 Provider to load all users at once
final usersProvider = StreamProvider<Map<String, String>>((ref) {
  return FirebaseFirestore.instance.collection("users").snapshots().map((
    snapshot,
  ) {
    final map = <String, String>{};
    for (var doc in snapshot.docs) {
      map[doc.id] = (doc.data()["email"] ?? "Unknown") as String;
    }
    return map;
  });
});
