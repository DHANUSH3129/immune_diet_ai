import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  String _goal     = 'Boost Immunity';
  String _diet     = 'Omnivore';
  String _activity = 'Lightly Active';
  final _ageCtrl    = TextEditingController(text: '28');
  final _heightCtrl = TextEditingController(text: '165');
  final _weightCtrl = TextEditingController(text: '62');

  final _goals = [
    ('🛡️', 'Boost Immunity', 'Strengthen natural defences'),
    ('⚡', 'Increase Energy', 'Fight fatigue naturally'),
    ('⚖️', 'Healthy Weight', 'Balanced, sustainable approach'),
    ('🧘', 'Reduce Inflammation', 'Anti-inflammatory nutrition'),
  ];
  final _diets = [
    ('🌱', 'Plant-Based', 'Fruits, veggies, legumes'),
    ('🥩', 'Omnivore', 'All food groups'),
    ('🚫', 'Gluten-Free', 'No wheat, rye, barley'),
    ('🥛', 'Dairy-Free', 'No milk products'),
  ];
  final _activities = [
    ('🪑', 'Sedentary', 'Mostly sitting'),
    ('🚶', 'Lightly Active', '1-3 days/week'),
    ('🏃', 'Very Active', '6-7 days/week'),
  ];

  Future<void> _finish() async {
    final p = context.read<AppProvider>();
    await p.saveOnboarding(
      goal: _goal, diet: _diet,
      age: int.tryParse(_ageCtrl.text) ?? 28,
      height: double.tryParse(_heightCtrl.text) ?? 165,
      weight: double.tryParse(_weightCtrl.text) ?? 62,
      activity: _activity,
    );
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(child: Column(children: [
        // Progress dots
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(children: List.generate(3, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 6),
            width: i == _step ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _step
                  ? AppColors.mintDark : AppColors.mintMid,
              borderRadius: BorderRadius.circular(4),
            ),
          ))),
        ),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 12),
            Text(_stepTitle(), style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 6),
            Text(_stepHint(), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),

            if (_step == 0) ..._buildOptions(
              items: _goals,
              selected: _goal,
              onSelect: (v) => setState(() => _goal = v),
            ),
            if (_step == 1) ..._buildOptions(
              items: _diets,
              selected: _diet,
              onSelect: (v) => setState(() => _diet = v),
            ),
            if (_step == 2) ...[
              Row(children: [
                Expanded(child: TextField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Age'),
                )),
                const SizedBox(width: 12),
                Expanded(child: DropdownButtonFormField<String>(
                  value: 'Female',
                  decoration: InputDecoration(
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.mintMid, width: 2),
                    ),
                  ),
                  items: ['Female','Male','Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (_) {},
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(
                  controller: _heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Height (cm)'),
                )),
                const SizedBox(width: 12),
                Expanded(child: TextField(
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Weight (kg)'),
                )),
              ]),
              const SizedBox(height: 20),
              Text('Activity Level',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ..._buildOptions(
                items: _activities,
                selected: _activity,
                onSelect: (v) => setState(() => _activity = v),
              ),
            ],
          ]),
        )),

        Padding(
          padding: const EdgeInsets.all(24),
          child: GradientButton(
            text: _step < 2 ? 'Continue →' : 'Build My Plan 🚀',
            loading: p.loading,
            onTap: _step < 2
                ? () => setState(() => _step++)
                : _finish,
          ),
        ),
      ])),
    );
  }

  List<Widget> _buildOptions({
    required List<(String, String, String)> items,
    required String selected,
    required ValueChanged<String> onSelect,
  }) => items.map((item) {
    final active = selected == item.$2;
    return GestureDetector(
      onTap: () => onSelect(item.$2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? AppColors.mint : Colors.white,
          border: Border.all(
              color: active ? AppColors.mintDark : Colors.transparent,
              width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Text(item.$1, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.$2, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
            if (item.$3.isNotEmpty)
              Text(item.$3, style: const TextStyle(
                  fontSize: 12, color: AppColors.textLight)),
          ]),
        ]),
      ),
    );
  }).toList();

  String _stepTitle() => ['What\'s your health goal? 🎯',
    'Dietary preferences? 🥗', 'Tell us about you 📊'][_step];
  String _stepHint()  => ['We\'ll personalise your meal plan',
    'Select what fits you best',
    'Helps us calculate your nutrition'][_step];
}
