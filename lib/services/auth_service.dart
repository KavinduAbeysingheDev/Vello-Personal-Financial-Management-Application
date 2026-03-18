import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmail(
      String email,
      String password,
      String name,
      ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      UserModel newUser = UserModel(
        uid: result.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newUser.toMap());

      // Initialize default budgets
      await _initializeDefaultBudgets(result.user!.uid);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Initialize default budgets for new user
  Future<void> _initializeDefaultBudgets(String userId) async {
    final defaultBudgets = [
      {'category': 'Food', 'limit': 500.0},
      {'category': 'Transportation', 'limit': 200.0},
      {'category': 'Entertainment', 'limit': 100.0},
      {'category': 'Shopping', 'limit': 300.0},
    ];

    final batch = _firestore.batch();
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    for (var budget in defaultBudgets) {
      final docRef = _firestore.collection('budgets').doc();
      batch.set(docRef, {
        'userId': userId,
        'category': budget['category'],
        'limit': budget['limit'],
        'spent': 0.0,
        'month': Timestamp.fromDate(currentMonth),
      });
    }

    await batch.commit();
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }