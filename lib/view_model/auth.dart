import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_simple/model/role.dart';
import 'package:todo_simple/repo/auth.dart';
import 'package:todo_simple/view_model/auth.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_simple/repo/auth.dart';
import 'package:todo_simple/model/role.dart';

class AuthViewModel extends StateNotifier<bool> {
  final IAuthRepository _repo;

  AuthViewModel(this._repo) : super(false); // false = not loading

  bool get isLoading => state;

  Future<AppUser?> signIn(String email, String password) async {
    state = true;
    try {
      return await _repo.signIn(email, password);
    } finally {
      state = false;
    }
  }

  Future<AppUser?> signUp(
    String email,
    String password,
    name,
    UserRole role,
  ) async {
    state = true;
    try {
      return await _repo.signUp(email, password, name, role);
    } finally {
      state = false;
    }
  }

  Future<void> signOut() => _repo.signOut();

  Stream<AppUser?> authStateChanges() => _repo.authStateChanges();
}

/// Firebase core instances
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
