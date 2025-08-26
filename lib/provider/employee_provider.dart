import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_simple/repo/employee_repo.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final employeeRepoProvider = Provider((ref) {
  return FirebaseEmployee(ref.watch(firestoreProvider));
});
