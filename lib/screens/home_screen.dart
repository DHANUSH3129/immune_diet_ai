import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'meal_plan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;
    final name = user?.name ?? 'User';
    final score = user?.immunityScore ?? 78;
    final streak = user?.streak ?? 1;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(slivers: [
        // Header
        SliverToBoxAdapter(child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE4F7ED), Color(0xFFF5EEF8)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
              24, MediaQuery.of(context).padding.top + 16, 24, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Good morning 👋',
                    style: TextStyle(fontSize: 13,
                        color: AppColors.textMid, fontWeight: FontWeight.w600)),
                Text(name,
                    style: Theme.of(context).textTheme.displaySmall),
                Text(
                  _todayDate(),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textLight),
                ),
              ]),
              const FirebaseBadge(),
            ],
          ),
        )),

        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // Immunity Score Card
            _immunityCard(context, score, streak),
            const SizedBox(height: 20),

            // Nutrients
            SectionHeader(title: 'Today\'s Nutrients'),
            const SizedBox(height: 12),
            _nutrientsCard(),
            const SizedBox(height: 20),

            // Meals
            SectionHeader(
              title: 'Today\'s Meals',
              action: 'See plan →',
              onAction: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MealPlanScreen())),
            ),
            const SizedBox(height: 12),
            _mealsRow(),
            const SizedBox(height: 20),

            // Tip
            SectionHeader(title: 'Immunity Tip'),
            const SizedBox(height: 12),
            _tipCard(),
            const SizedBox(height: 8),
          ])),
        ),
      ]),
    );
  }

  Widget _immunityCard(BuildContext ctx, int score, int streak) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          // Score ring
          SizedBox(width: 80, height: 80, child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 80, height: 80,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 7,
                  backgroundColor: const Color(0xFFF0EAF8),
                  valueColor: const AlwaysStoppedAnimation(AppColors.mintDark),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text('$score',
                  style: const TextStyle(
                      fontFamily: 'DmSerifDisplay',
                      fontSize: 22,
                      color: AppColors.mintDeep,
                      fontStyle: FontStyle.italic)),
            ],
          )),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Immunity Score',
                  style: const TextStyle(fontFamily: 'DmSerifDisplay',
                      fontSize: 16, color: AppColors.textDark)),
              const SizedBox(height: 4),
              const Text(
                'Your immune health is ↑ 5 pts from last week!',
                style: TextStyle(fontSize: 12,
                    color: AppColors.textLight, height: 1.4),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: [
                mintTag('Good'),
                lavTag('Day $streak streak'),
              ]),
            ],
          )),
        ]),
      );

  Widget _nutrientsCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12, offset: const Offset(0, 2))],
    ),
    child: Column(children: [
      NutrientBar(emoji: '🍊', name: 'Vitamin C',
          percent: 0.72, value: '72mg/90mg',
          colors: [AppColors.mintDark, const Color(0xFF5DCAA5)]),
      const SizedBox(height: 10),
      NutrientBar(emoji: '☀️', name: 'Vitamin D',
          percent: 0.45, value: '9µg/20µg',
          colors: [AppColors.peachDark, const Color(0xFFEF9F27)]),
      const SizedBox(height: 10),
      NutrientBar(emoji: '🥦', name: 'Zinc',
          percent: 0.60, value: '5mg/8mg',
          colors: [AppColors.lavenderDark, AppColors.lavenderMid]),
      const SizedBox(height: 10),
      NutrientBar(emoji: '🐟', name: 'Omega-3',
          percent: 0.30, value: '0.6g/1.6g',
          colors: [const Color(0xFF378ADD), const Color(0xFF85B7EB)]),
    ]),
  );

  Widget _mealsRow() => SizedBox(
    height: 140,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _mealMini('🥗', 'Smoothie Bowl', '320 kcal', '+Vit C'),
        _mealMini('🍲', 'Turmeric Soup', '410 kcal', '+Antioxidants'),
        _mealMini('🥑', 'Grain Bowl', '520 kcal', '+Zinc'),
        _mealMini('🫐', 'Berry Pudding', '180 kcal', '+Antioxidants'),
      ],
    ),
  );

  Widget _mealMini(String e, String n, String c, String b) =>
      Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8, offset: const Offset(0,2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 6),
          Text(n, style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.textDark)),
          Text(c, style: const TextStyle(
              fontSize: 11, color: AppColors.textLight)),
          const SizedBox(height: 4),
          Text(b, style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: AppColors.mintDeep)),
        ]),
      );

  Widget _tipCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.lavender, AppColors.mint],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('💡', style: TextStyle(fontSize: 28)),
      const SizedBox(width: 12),
      const Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fermented foods = gut immunity',
              style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w700, color: AppColors.textDark)),
          SizedBox(height: 4),
          Text(
            '70% of your immune system lives in your gut. Adding yogurt or kimchi to 1 meal daily boosts beneficial bacteria.',
            style: TextStyle(fontSize: 12,
                color: AppColors.textMid, height: 1.5),
          ),
        ],
      )),
    ]),
  );

  String _todayDate() {
    final d = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Monday','Tuesday','Wednesday','Thursday',
        'Friday','Saturday','Sunday'];
    return '${days[d.weekday-1]} · ${months[d.month-1]} ${d.day}, ${d.year}';
  }
}
