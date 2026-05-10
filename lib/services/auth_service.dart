import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/meal_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Auth state stream ────────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ── Register ─────────────────────────────────────────────────────────────
  Future<UserModel?> register(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = UserModel(
      uid:   cred.user!.uid,
      name:  name,
      email: email,
    );
    await _db.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }

  // ── Login ────────────────────────────────────────────────────────────────
  Future<UserModel?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return getUser(cred.user!.uid);
  }

  // ── Sign out ─────────────────────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── Get user ─────────────────────────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  // ── Update user profile ───────────────────────────────────────────────────
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ── Save complete onboarding profile ─────────────────────────────────────
  Future<void> saveOnboarding(String uid, {
    required String goal,
    required String diet,
    required int age,
    required double height,
    required double weight,
    required String activity,
  }) async {
    await _db.collection('users').doc(uid).update({
      'goal': goal, 'diet': diet, 'age': age,
      'height': height, 'weight': weight, 'activity': activity,
      'immunityScore': 78, 'streak': 1,
    });

    // Save default 7-day meal plan
    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    for (final day in days) {
      await _db
          .collection('users').doc(uid)
          .collection('mealPlans').doc(day)
          .set({'meals': defaultMeals.map((m) => m.toMap()).toList()});
    }
  }
}
