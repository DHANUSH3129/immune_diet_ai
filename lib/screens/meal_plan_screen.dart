import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../services/firestore_service.dart';
import '../models/meal_model.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});
  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final _days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
  String _selectedDay = 'Mon';
  List<MealModel> _meals = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadMeals(); }

  Future<void> _loadMeals() async {
    setState(() => _loading = true);
    final uid = context.read<AppProvider>().user?.uid;
    if (uid != null) {
      final meals = await FirestoreService().getMealPlan(uid, _selectedDay);
      setState(() { _meals = meals; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    body: Column(children: [
      // Header
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDE8D8), Color(0xFFF5EEF8)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, MediaQuery.of(context).padding.top + 16, 24, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Meal Plan 🍽️',
                  style: Theme.of(context).textTheme.displaySmall),
              const Text('AI-curated for your immunity goals',
                  style: TextStyle(fontSize: 13, color: AppColors.textLight)),
            ]),
            const FirebaseBadge(label: '🔥 Saved'),
          ],
        ),
      ),

      // Day tabs
      Container(
        height: 52,
        margin: const EdgeInsets.only(top: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _days.length,
          itemBuilder: (_, i) {
            final d = _days[i];
            final active = d == _selectedDay;
            return GestureDetector(
              onTap: () { setState(() => _selectedDay = d); _loadMeals(); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: active ? const LinearGradient(
                    colors: [AppColors.mintDark, AppColors.lavenderDark],
                  ) : null,
                  color: active ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6)],
                ),
                child: Text(d, style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.textLight)),
              ),
            );
          },
        ),
      ),

      // Meals list
      Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.mintDark))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _meals.length + 1,
              itemBuilder: (_, i) {
                if (i == _meals.length) return _totalCard();
                return _mealCard(_meals[i]);
              },
            )),
    ]),
  );

  Widget _mealCard(MealModel m) {
    final bgMap = {
      'breakfast': AppColors.mint,
      'lunch':     AppColors.peach,
      'snack':     AppColors.lavender,
      'dinner':    const Color(0xFFE8F1FB),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        // Header row
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: bgMap[m.mealTime] ?? AppColors.mint,
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(m.emoji,
                      style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.mealTime.toUpperCase() + ' · ' + m.timeLabel,
                  style: const TextStyle(fontSize: 11,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600)),
              Text(m.name, style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
            ]),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFF5F0FA)),

        // Ingredients
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            ...m.ingredients.map((ing) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: [
                Container(width: 6, height: 6,
                    decoration: const BoxDecoration(
                        color: AppColors.mintDark, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(ing.name,
                    style: const TextStyle(fontSize: 13,
                        color: AppColors.textMid))),
                Text(ing.amount, style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
              ]),
            )),

            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 4, children: m.boostTags
                .map((t) => mintTag(t)).toList()),

            const SizedBox(height: 12),
            Row(children: [
              MacroChip(value: '${m.calories}', label: 'kcal'),
              const SizedBox(width: 8),
              MacroChip(value: '${m.protein.toInt()}g', label: 'protein'),
              const SizedBox(width: 8),
              MacroChip(value: '${m.carbs.toInt()}g', label: 'carbs'),
              const SizedBox(width: 8),
              MacroChip(value: '${m.fats.toInt()}g', label: 'fats'),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _totalCard() {
    final total = _meals.fold(0, (s, m) => s + m.calories);
    final prot  = _meals.fold(0.0, (s, m) => s + m.protein);
    final carbs = _meals.fold(0.0, (s, m) => s + m.carbs);
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('DAILY TOTAL', style: TextStyle(
                fontSize: 11, color: AppColors.textLight,
                fontWeight: FontWeight.w600)),
            Text('$total kcal', style: const TextStyle(
                fontFamily: 'DmSerifDisplay',
                fontSize: 20, color: AppColors.textDark)),
          ]),
          Wrap(spacing: 6, children: [
            mintTag('${prot.toInt()}g protein'),
            lavTag('${carbs.toInt()}g carbs'),
          ]),
        ],
      ),
    );
  }
}
