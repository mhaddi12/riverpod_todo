import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_simple/model/role.dart';
import 'package:todo_simple/repo/employee_repo.dart'; // EmployeeRepo

class EmployeeNotifier extends StateNotifier<AsyncValue<List<AppUser>>> {
  final EmployeeRepo _repo;
  StreamSubscription<List<AppUser>>? _subscription;

  EmployeeNotifier(this._repo) : super(const AsyncValue.loading()) {
    _listenEmployees();
  }

  void _listenEmployees() {
    _subscription = _repo.showEmployeeList().listen(
      (employees) {
        state = AsyncValue.data(employees);
      },
      onError: (err, stack) {
        state = AsyncValue.error(err, stack);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
