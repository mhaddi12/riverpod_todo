import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_simple/repo/auth.dart';

import '../model/role.dart';
import '../view_model/auth.dart' show AuthViewModel, firebaseAuthProvider;
import 'todo_provider.dart';

/// Repository provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return FirebaseAuthRepository(
    ref.read(firebaseAuthProvider),
    ref.read(firestoreProvider),
  );
});

/// Auth state provider (current user stream)
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Auth ViewModel provider (for login/signup + loading state)
final authViewModelProvider = StateNotifierProvider<AuthViewModel, bool>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthViewModel(repo);
});
