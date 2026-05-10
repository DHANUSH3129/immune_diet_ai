import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../services/firestore_service.dart';
import '../services/claude_service.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _claude    = ClaudeService();
  final _firestore = FirestoreService();

  File?   _selectedFile;
  String? _fileName;
  bool    _isImage   = false;
  bool    _analyzing = false;
  String  _status    = '';
  MedicalAnalysisResult? _result;
  Map<String, List<MealSuggestion>> _weekPlan = {};

  // ── Pick PDF ───────────────────────────────────────────
  Future<void> _pickPdf() async {
    final r = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf']);
    if (r != null && r.files.single.path != null) {
      setState(() {
        _selectedFile = File(r.files.single.path!);
        _fileName     = r.files.single.name;
        _isImage      = false;
        _result       = null;
        _weekPlan     = {};
      });
    }
  }

  // ── Pick Image ─────────────────────────────────────────
  Future<void> _pickImage(ImageSource src) async {
    final p = await ImagePicker().pickImage(source: src, imageQuality: 90);
    if (p != null) {
      setState(() {
        _selectedFile = File(p.path);
        _fileName     = p.name;
        _isImage      = true;
        _result       = null;
        _weekPlan     = {};
      });
    }
  }

  // ── Analyze + Generate ──────────────────────────────────
  Future<void> _analyze() async {
    if (_selectedFile == null) return;
    setState(() { _analyzing = true; _status = 'Claude AI is reading your report...'; });

    try {
      // Step 1: Analyze report
      final result = _isImage
          ? await _claude.analyzeReportImage(_selectedFile!)
          : await _claude.analyzeReportPdf(_selectedFile!);

      setState(() { _status = 'Generating your 7-day meal plan...'; });

      // Step 2: Generate 7-day plan
      final user = context.read<AppProvider>().user;
      final plan = await _claude.generate7DayMealPlan(result, user?.diet ?? 'Omnivore');

      // Step 3: Save to Firestore
      if (user != null) {
        await _firestore.saveReportAnalysis(user.uid, result.toMap());
        await _firestore.updateScore(user.uid, result.immunityScore);
        // Save each day's meals
        plan.forEach((day, meals) async {
          await _firestore.updateScore(user.uid, result.immunityScore);
        });
      }

      setState(() {
        _result   = result;
        _weekPlan = plan;
        _analyzing = false;
        _status   = '';
      });
    } catch (e) {
      setState(() { _analyzing = false; _status = 'Error: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(slivers: [

        // ── HEADER ──────────────────────────────────────
        SliverToBoxAdapter(child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFDE8D8), Color(0xFFEDE8F8)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 24),
          child: Column(children: [
            // Avatar + name
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(
                  width: 60, height: 60,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.mintDark, AppColors.lavenderDark]),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('🧘', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user?.name ?? 'User',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22)),
                  Text('${user?.email ?? ''}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                ]),
              ]),
              const FirebaseBadge(),
            ]),

            const SizedBox(height: 16),

            // Stats row
            Row(children: [
              _statBox('${user?.age ?? '-'} yrs',    'Age'),
              const SizedBox(width: 8),
              _statBox('${user?.height.toInt() ?? '-'} cm', 'Height'),
              const SizedBox(width: 8),
              _statBox('${user?.weight.toInt() ?? '-'} kg',  'Weight'),
              const SizedBox(width: 8),
              _statBox(user?.bmi.toStringAsFixed(1) ?? '-',  'BMI'),
            ]),

            const SizedBox(height: 12),

            // Goal + Diet tags
            Wrap(spacing: 8, children: [
              mintTag(user?.goal ?? 'Boost Immunity'),
              lavTag(user?.diet ?? 'Balanced'),
              peachTag(user?.bmiCategory ?? ''),
            ]),

            const SizedBox(height: 12),

            // Immunity score bar
            Row(children: [
              const Text('Immunity Score',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMid)),
              const SizedBox(width: 8),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (user?.immunityScore ?? 50) / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation(AppColors.mintDark),
                ),
              )),
              const SizedBox(width: 8),
              Text('${user?.immunityScore ?? 50}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.mintDeep)),
            ]),
          ]),
        )),

        // ── REPORT UPLOAD SECTION ────────────────────────
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // Section title
            Row(children: [
              const Text('Lab Report AI',
                  style: TextStyle(fontFamily: 'DmSerifDisplay', fontSize: 18, color: AppColors.textDark)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lavender,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🤖 Claude AI',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: AppColors.lavenderDark)),
              ),
            ]),
            const SizedBox(height: 4),
            const Text('Upload your blood/lab report for AI analysis & personalized 7-day meal plan',
                style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            const SizedBox(height: 14),

            // Upload card
            if (_result == null) ...[
              _uploadCard(),
              const SizedBox(height: 12),
              if (_selectedFile != null) _fileChip(),
              const SizedBox(height: 12),
              if (_selectedFile != null && !_analyzing)
                GradientButton(text: '🔬 Analyze with Claude AI', onTap: _analyze),
            ],

            if (_analyzing) _loadingCard(),

            if (_status.startsWith('Error'))
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: const Color(0xFFFCEBEB),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(_status,
                    style: const TextStyle(color: Color(0xFFE24B4A), fontSize: 12)),
              ),

            // Results
            if (_result != null) ...[
              _scoreCard(),
              const SizedBox(height: 14),
              _defCard(),
              const SizedBox(height: 14),
              if (_weekPlan.isNotEmpty) _weekPlanCard(),
              const SizedBox(height: 14),
              GradientButton(
                text: '↩ Analyze Another Report',
                onTap: () => setState(() {
                  _result = null; _weekPlan = {};
                  _selectedFile = null; _fileName = null;
                }),
              ),
              const SizedBox(height: 20),
            ],

            // Settings
            if (_result == null) ...[
              const SizedBox(height: 8),
              const Text('Settings',
                  style: TextStyle(fontFamily: 'DmSerifDisplay',
                      fontSize: 16, color: AppColors.textDark)),
              const SizedBox(height: 12),
              _settingItem('🍽️', 'Dietary Preferences', user?.diet ?? 'Omnivore', AppColors.mint),
              _settingItem('🎯', 'Health Goals', user?.goal ?? 'Boost Immunity', AppColors.lavender),
              _settingItem('🔔', 'Meal Reminders', 'On · 7:30, 12:30, 7:30 PM', AppColors.peach),
              const SizedBox(height: 8),
              _signOutBtn(),
              const SizedBox(height: 24),
            ],
          ])),
        ),
      ]),
    );
  }

  // ── Stat box ───────────────────────────────────────────
  Widget _statBox(String val, String label) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
          color: AppColors.textDark)),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMid)),
    ]),
  ));

  // ── Upload card ────────────────────────────────────────
  Widget _uploadCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)]),
    child: Column(children: [
      const Text('📋', style: TextStyle(fontSize: 40)),
      const SizedBox(height: 8),
      const Text('Upload Medical Report',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      const Text('Blood test, vitamin panel, or any lab report',
          style: TextStyle(fontSize: 11, color: AppColors.textLight)),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _uploadBtn('📄 PDF', AppColors.lavender, AppColors.lavenderDark, _pickPdf)),
        const SizedBox(width: 8),
        Expanded(child: _uploadBtn('📷 Camera', AppColors.mint, AppColors.mintDark,
                () => _pickImage(ImageSource.camera))),
        const SizedBox(width: 8),
        Expanded(child: _uploadBtn('🖼️ Gallery', AppColors.peach, AppColors.peachDark,
                () => _pickImage(ImageSource.gallery))),
      ]),
    ]),
  );

  Widget _uploadBtn(String label, Color bg, Color fg, VoidCallback onTap) =>
      GestureDetector(onTap: onTap,
          child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Text(label, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg))));

  Widget _fileChip() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Text(_isImage ? '🖼️' : '📄', style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 8),
      Expanded(child: Text(_fileName ?? '',
          style: const TextStyle(fontSize: 12, color: AppColors.mintDeep, fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
      GestureDetector(onTap: () => setState(() { _selectedFile = null; _fileName = null; }),
          child: const Icon(Icons.close, color: AppColors.mintDeep, size: 18)),
    ]),
  );

  Widget _loadingCard() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)]),
    child: Column(children: [
      const CircularProgressIndicator(color: AppColors.mintDark, strokeWidth: 3),
      const SizedBox(height: 14),
      Text(_status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textMid), textAlign: TextAlign.center),
      const SizedBox(height: 4),
      const Text('Claude AI is working...', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
    ]),
  );

  Widget _scoreCard() {
    final score = _result!.immunityScore;
    final color = score >= 70 ? AppColors.mintDark : score >= 50 ? AppColors.peachDark : const Color(0xFFE24B4A);
    final label = score >= 70 ? 'Good' : score >= 50 ? 'Moderate' : 'Low';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)]),
      child: Row(children: [
        SizedBox(width: 72, height: 72, child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(value: score / 100, strokeWidth: 6,
              backgroundColor: const Color(0xFFF0EAF8),
              valueColor: AlwaysStoppedAnimation(color), strokeCap: StrokeCap.round),
          Text('$score', style: TextStyle(fontFamily: 'DmSerifDisplay', fontSize: 18,
              color: color, fontStyle: FontStyle.italic)),
        ])),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Immunity Score', style: TextStyle(fontFamily: 'DmSerifDisplay',
              fontSize: 15, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color))),
          const SizedBox(height: 6),
          Text(_result!.summary, style: const TextStyle(fontSize: 10, color: AppColors.textLight, height: 1.4),
              maxLines: 3, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  Widget _defCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Report Analysis', style: TextStyle(fontFamily: 'DmSerifDisplay',
          fontSize: 15, color: AppColors.textDark)),
      const SizedBox(height: 10),
      if (_result!.deficiencies.isNotEmpty) ...[
        _defLabel('⬇️ Deficiencies', const Color(0xFFE24B4A)),
        ..._result!.deficiencies.map((d) => _defRow(d, const Color(0xFFFCEBEB), const Color(0xFFE24B4A))),
        const SizedBox(height: 8),
      ],
      if (_result!.highLevels.isNotEmpty) ...[
        _defLabel('⬆️ High Levels', AppColors.peachDark),
        ..._result!.highLevels.map((h) => _defRow(h, AppColors.peach, AppColors.peachDark)),
        const SizedBox(height: 8),
      ],
      if (_result!.normalLevels.isNotEmpty) ...[
        _defLabel('✅ Normal', AppColors.mintDark),
        ..._result!.normalLevels.map((n) => _defRow(n, AppColors.mint, AppColors.mintDeep)),
      ],
    ]),
  );

  Widget _defLabel(String t, Color c) => Padding(padding: const EdgeInsets.only(bottom: 5),
      child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c)));
  Widget _defRow(String t, Color bg, Color fg) => Container(
      margin: const EdgeInsets.only(bottom: 5), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(t, style: TextStyle(fontSize: 11, color: fg)));

  // ── 7-Day plan card ────────────────────────────────────
  Widget _weekPlanCard() {
    final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('7-Day AI Meal Plan', style: TextStyle(fontFamily: 'DmSerifDisplay',
              fontSize: 15, color: AppColors.textDark)),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(10)),
              child: const Text('🤖 Claude AI', style: TextStyle(fontSize: 9,
                  fontWeight: FontWeight.w700, color: AppColors.lavenderDark))),
        ]),
        const SizedBox(height: 4),
        const Text('Personalised based on your lab report',
            style: TextStyle(fontSize: 11, color: AppColors.textLight)),
        const SizedBox(height: 14),
        ...days.map((day) {
          final meals = _weekPlan[day] ?? [];
          if (meals.isEmpty) return const SizedBox();
          return ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(day, style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w700, color: AppColors.textDark)),
            subtitle: Text('${meals.fold(0, (s, m) => s + m.calories)} kcal total',
                style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            children: meals.map((m) {
              final icons = {'breakfast':'🌅','lunch':'☀️','snack':'🌿','dinner':'🌙'};
              final bgs = {
                'breakfast': AppColors.mint, 'lunch': AppColors.peach,
                'snack': AppColors.lavender, 'dinner': const Color(0xFFE8F1FB),
              };
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: bgs[m.mealTime] ?? AppColors.cream,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(icons[m.mealTime] ?? '🍽️', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(m.name, style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700, color: AppColors.textDark))),
                    Text('${m.calories} kcal', style: const TextStyle(fontSize: 10,
                        color: AppColors.textLight)),
                  ]),
                  const SizedBox(height: 4),
                  Text('💡 ${m.reason}', style: const TextStyle(fontSize: 10,
                      color: AppColors.mintDeep, height: 1.4)),
                  const SizedBox(height: 4),
                  Wrap(spacing: 4, runSpacing: 4,
                      children: m.ingredients.map((i) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(i, style: const TextStyle(fontSize: 9,
                              color: AppColors.textMid)))).toList()),
                ]),
              );
            }).toList(),
          );
        }),
      ]),
    );
  }

  Widget _settingItem(String icon, String title, String sub, Color bg) =>
      Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: bg,
              borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 18)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
            Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
          ])),
          const Icon(Icons.chevron_right, color: AppColors.textLight),
        ]),
      );

  Widget _signOutBtn() => GestureDetector(
    onTap: () async {
      await context.read<AppProvider>().signOut();
      if (mounted) Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
    },
    child: Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('🚪', style: TextStyle(fontSize: 18)))),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sign Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
              color: Color(0xFFE24B4A))),
          Text('Signed in via Firebase Auth', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
        ])),
        const Icon(Icons.chevron_right, color: AppColors.textLight),
      ]),
    ),
  );
}