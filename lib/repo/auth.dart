import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_simple/model/role.dart';

abstract class IAuthRepository {
  User? get currentUser;
  bool get isLoading;
  Stream<AppUser?> authStateChanges();
  Future<AppUser?> signIn(String email, String password);
  Future<AppUser?> signUp(
    String email,
    String password,
    String name,
    UserRole role,
  );
  Future<void> signOut();
}

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebaseAuthRepository(this.auth, this.firestore);

  bool _isLoading = false;

  @override
  bool get isLoading => _isLoading;

  @override
  User? get currentUser => auth.currentUser;

  @override
  Stream<AppUser?> authStateChanges() {
    return auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      final doc = await firestore.collection("users").doc(user.uid).get();
      if (!doc.exists || doc.data() == null) return null;

      return AppUser.fromJson(doc.data()!);
    });
  }

  @override
  Future<AppUser?> signIn(String email, String password) async {
    _isLoading = true;
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await firestore
          .collection("users")
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        throw Exception("User profile not found in Firestore");
      }

      return AppUser.fromJson(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<AppUser?> signUp(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    _isLoading = true;
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = AppUser(
        uid: credential.user!.uid,
        email: email,
        name: name,
        role: role,
      );

      await firestore.collection("users").doc(user.uid).set(user.toJson());
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> signOut() => auth.signOut();

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please log in instead.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'weak-password':
        return 'Password must be at least 6 characters long.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
