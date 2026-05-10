import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final FirestoreService _fs = FirestoreService();

  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user    => _user;
  bool       get loading => _loading;
  String?    get error   => _error;
  bool       get isLoggedIn => _user != null;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String? v) { _error = v; notifyListeners(); }
  void clearError() { _error = null; notifyListeners(); }

  // ── Register ─────────────────────────────────────────────────────────────
  Future<bool> register(String name, String email, String pass) async {
    _setLoading(true); _setError(null);
    try {
      _user = await _auth.register(name, email, pass);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError(_friendlyError(e.toString()));
      return false;
    } finally { _setLoading(false); }
  }

  // ── Login ────────────────────────────────────────────────────────────────
  Future<bool> login(String email, String pass) async {
    _setLoading(true); _setError(null);
    try {
      _user = await _auth.login(email, pass);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError(_friendlyError(e.toString()));
      return false;
    } finally { _setLoading(false); }
  }

  // ── Sign out ─────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  // ── Restore session ───────────────────────────────────────────────────────
  Future<void> restoreSession() async {
    final fbUser = _auth.currentUser;
    if (fbUser != null) {
      _user = await _auth.getUser(fbUser.uid);
      notifyListeners();
    }
  }

  // ── Save onboarding ───────────────────────────────────────────────────────
  Future<void> saveOnboarding({
    required String goal, required String diet,
    required int age, required double height,
    required double weight, required String activity,
  }) async {
    if (_user == null) return;
    await _auth.saveOnboarding(_user!.uid,
        goal: goal, diet: diet, age: age,
        height: height, weight: weight, activity: activity);
    _user = _user!.copyWith(
        goal: goal, diet: diet, age: age,
        height: height, weight: weight, activity: activity);
    notifyListeners();
  }

  // ── Update score ──────────────────────────────────────────────────────────
  Future<void> updateScore(int score) async {
    if (_user == null) return;
    await _fs.updateScore(_user!.uid, score);
    _user = _user!.copyWith(immunityScore: score);
    notifyListeners();
  }

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use')) return 'Email already registered.';
    if (raw.contains('invalid-email'))        return 'Invalid email address.';
    if (raw.contains('weak-password'))        return 'Password too weak (min 6 chars).';
    if (raw.contains('user-not-found'))       return 'No account found with that email.';
    if (raw.contains('wrong-password'))       return 'Incorrect password.';
    if (raw.contains('network'))              return 'Network error. Check connection.';
    return 'Something went wrong. Try again.';
  }
}
