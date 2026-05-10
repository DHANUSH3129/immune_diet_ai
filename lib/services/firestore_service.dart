import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_model.dart';
import '../models/chat_message.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Meal Plans ───────────────────────────────────────────────────────────
  Future<List<MealModel>> getMealPlan(String uid, String day) async {
    final doc = await _db
        .collection('users').doc(uid)
        .collection('mealPlans').doc(day)
        .get();
    if (!doc.exists) return defaultMeals;
    final meals = doc.data()?['meals'] as List? ?? [];
    return meals.map((m) => MealModel.fromMap(m)).toList();
  }

  Future<void> saveMealPlan(
      String uid, String day, List<MealModel> meals) async {
    await _db
        .collection('users').doc(uid)
        .collection('mealPlans').doc(day)
        .set({'meals': meals.map((m) => m.toMap()).toList()});
  }

  // ── Chat History ─────────────────────────────────────────────────────────
  Stream<List<ChatMessage>> chatStream(String uid) {
    return _db
        .collection('users').doc(uid)
        .collection('chatHistory')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatMessage.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> sendMessage(String uid, String role, String text) async {
    await _db
        .collection('users').doc(uid)
        .collection('chatHistory')
        .add({'role': role, 'text': text, 'timestamp': FieldValue.serverTimestamp()});
  }

  // ── Immunity Score ───────────────────────────────────────────────────────
  Future<void> updateScore(String uid, int score) async {
    await _db.collection('users').doc(uid)
        .update({'immunityScore': score});
  }

  // ── Streak ───────────────────────────────────────────────────────────────
  Future<void> updateStreak(String uid, int streak) async {
    await _db.collection('users').doc(uid)
        .update({'streak': streak});
  }
  Future<void> saveReportAnalysis(
      String uid, Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('reports')
        .add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
