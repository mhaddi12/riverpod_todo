import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;

import 'package:todo_simple/model/role.dart';

abstract class EmployeeRepo {
  Stream<List<AppUser>> showEmployeeList();
}

class FirebaseEmployee implements EmployeeRepo {
  final FirebaseFirestore firestore;
  FirebaseEmployee(this.firestore);

  @override
  Stream<List<AppUser>> showEmployeeList() {
    return firestore
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return AppUser.fromJson(data);
          }).toList();
        });
  }
}
