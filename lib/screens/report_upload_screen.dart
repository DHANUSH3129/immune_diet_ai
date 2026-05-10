import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class ReportUploadScreen extends StatefulWidget {
  const ReportUploadScreen({super.key});
  @override
  State<ReportUploadScreen> createState() => _ReportUploadScreenState();
}

class _ReportUploadScreenState extends State<ReportUploadScreen> {
  final _claude = claudeService();
  final _firestore = FirestoreService();

  File? _selectedFile;
  String? _fileName;
  bool _isImage = false;
  bool _analyzing = false;
  String _status = '';
  MedicalAnalysisResult? _result;
  List<MealSuggestion> _meals = [];

  // ── Pick PDF ───────────────────────────────────────────
  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        _isImage = false;
        _result = null;
        _meals = [];
      });
    }
  }

  // ── Pick Image ─────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked != null) {
      setState(() {
        _selectedFile = File(picked.path);
        _fileName = picked.name;
        _isImage = true;
        _result = null;
        _meals = [];
      });
    }
  }

  // ── Analyze Report ─────────────────────────────────────
  Future<void> _analyzeReport() async {
    if (_selectedFile == null) return;
    setState(() { _analyzing = true; _status = 'Reading your medical report...'; });

    try {
      // Step 1: Analyze report
      MedicalAnalysisResult result;
      if (_isImage) {
        result = await _gemini.analyzeReportImage(_selectedFile!);
      } else {
        result = await _gemini.analyzeReportPdf(_selectedFile!);
      }
      setState(() { _status = 'Generating your personalized meal plan...'; });

      // Step 2: Generate meal plan
      final user = context.read<AppProvider>().user;
      final meals = await _gemini.generateMealPlan(result, user?.diet ?? 'Omnivore');

      // Step 3: Save to Firestore
      if (user != null) {
        await _firestore.saveReportAnalysis(user.uid, result.toMap());
        await _firestore.updateScore(user.uid, result.immunityScore);
      }

      setState(() {
        _result = result;
        _meals = meals;
        _analyzing = false;
        _status = '';
      });
    } catch (e) {
      setState(() {
        _analyzing = false;
        _status = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(children: [
        // Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE4F7ED), Color(0xFFF5EEF8)],
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
                Text('Lab Report AI', style: Theme.of(context).textTheme.displaySmall),
                const Text('Upload your report for AI analysis',
                    style: TextStyle(fontSize: 13, color: AppColors.textLight)),
              ]),
              const FirebaseBadge(label: '🤖 Gemini AI'),
            ],
          ),
        ),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [

            // Upload options
            if (_result == null) ...[
              _uploadCard(),
              const SizedBox(height: 16),
              if (_selectedFile != null) _selectedFileCard(),
              const SizedBox(height: 16),
              if (_selectedFile != null && !_analyzing)
                GradientButton(
                  text: '🔬 Analyze with Gemini AI',
                  onTap: _analyzeReport,
                ),
            ],

            // Loading
            if (_analyzing) _loadingCard(),

            // Error
            if (_status.startsWith('Error'))
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEBEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_status,
                    style: const TextStyle(color: Color(0xFFE24B4A), fontSize: 13)),
              ),

            // Results
            if (_result != null) ...[
              _immunityScoreCard(),
              const SizedBox(height: 16),
              _deficienciesCard(),
              const SizedBox(height: 16),
              if (_meals.isNotEmpty) _mealPlanCard(),
              const SizedBox(height: 16),
              GradientButton(
                text: '↩ Analyze Another Report',
                onTap: () => setState(() {
                  _result = null; _meals = []; _selectedFile = null; _fileName = null;
                }),
              ),
            ],
          ]),
        )),
      ]),
    );
  }

  // ── Upload Card ────────────────────────────────────────
  Widget _uploadCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
    ),
    child: Column(children: [
      const Text('📋', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      const Text('Upload Medical Report',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.textDark)),
      const SizedBox(height: 4),
      const Text('Blood test, vitamin panel, or any lab report',
          style: TextStyle(fontSize: 12, color: AppColors.textLight)),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _uploadBtn('📄 PDF', AppColors.lavender, AppColors.lavenderDark, _pickPdf)),
        const SizedBox(width: 10),
        Expanded(child: _uploadBtn('📷 Camera', AppColors.mint, AppColors.mintDark,
                () => _pickImage(ImageSource.camera))),
        const SizedBox(width: 10),
        Expanded(child: _uploadBtn('🖼️ Gallery', AppColors.peach, AppColors.peachDark,
                () => _pickImage(ImageSource.gallery))),
      ]),
    ]),
  );

  Widget _uploadBtn(String label, Color bg, Color fg, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
        ),
      );

  // ── Selected File Card ─────────────────────────────────
  Widget _selectedFileCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.mint,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(children: [
      Text(_isImage ? '🖼️' : '📄', style: const TextStyle(fontSize: 24)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('File selected', style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mintDeep)),
        Text(_fileName ?? '', style: const TextStyle(fontSize: 13, color: AppColors.mintDeep),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
      GestureDetector(
        onTap: () => setState(() { _selectedFile = null; _fileName = null; }),
        child: const Icon(Icons.close, color: AppColors.mintDeep, size: 18),
      ),
    ]),
  );

  // ── Loading Card ───────────────────────────────────────
  Widget _loadingCard() => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
    ),
    child: Column(children: [
      const CircularProgressIndicator(color: AppColors.mintDark, strokeWidth: 3),
      const SizedBox(height: 16),
      Text(_status, style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMid),
          textAlign: TextAlign.center),
      const SizedBox(height: 8),
      const Text('Gemini AI is reading your report...',
          style: TextStyle(fontSize: 12, color: AppColors.textLight),
          textAlign: TextAlign.center),
    ]),
  );

  // ── Immunity Score Card ────────────────────────────────
  Widget _immunityScoreCard() {
    final score = _result!.immunityScore;
    final color = score >= 70 ? AppColors.mintDark
        : score >= 50 ? AppColors.peachDark
        : const Color(0xFFE24B4A);
    final label = score >= 70 ? 'Good' : score >= 50 ? 'Moderate' : 'Low';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
      ),
      child: Row(children: [
        SizedBox(width: 80, height: 80, child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 7,
              backgroundColor: const Color(0xFFF0EAF8),
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
            Text('$score', style: TextStyle(
                fontFamily: 'DmSerifDisplay', fontSize: 20,
                color: color, fontStyle: FontStyle.italic)),
          ],
        )),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Immunity Score', style: TextStyle(
              fontFamily: 'DmSerifDisplay', fontSize: 16, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20)),
            child: Text(label, style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ),
          const SizedBox(height: 6),
          Text(_result!.summary,
              style: const TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.4),
              maxLines: 3, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  // ── Deficiencies Card ──────────────────────────────────
  Widget _deficienciesCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Report Analysis', style: TextStyle(
          fontFamily: 'DmSerifDisplay', fontSize: 16, color: AppColors.textDark)),
      const SizedBox(height: 12),

      if (_result!.deficiencies.isNotEmpty) ...[
        _sectionLabel('⬇️ Deficiencies', const Color(0xFFE24B4A)),
        ..._result!.deficiencies.map((d) => _resultRow(d, const Color(0xFFFCEBEB), const Color(0xFFE24B4A))),
        const SizedBox(height: 10),
      ],

      if (_result!.highLevels.isNotEmpty) ...[
        _sectionLabel('⬆️ High Levels', AppColors.peachDark),
        ..._result!.highLevels.map((h) => _resultRow(h, AppColors.peach, AppColors.peachDark)),
        const SizedBox(height: 10),
      ],

      if (_result!.normalLevels.isNotEmpty) ...[
        _sectionLabel('✅ Normal', AppColors.mintDark),
        ..._result!.normalLevels.map((n) => _resultRow(n, AppColors.mint, AppColors.mintDeep)),
      ],
    ]),
  );

  Widget _sectionLabel(String label, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(label, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w700, color: color)),
  );

  Widget _resultRow(String text, Color bg, Color fg) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: TextStyle(fontSize: 12, color: fg)),
  );

  // ── AI Meal Plan Card ──────────────────────────────────
  Widget _mealPlanCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('AI Meal Plan', style: TextStyle(
            fontFamily: 'DmSerifDisplay', fontSize: 16, color: AppColors.textDark)),
        const SizedBox(width: 8),
        const FirebaseBadge(label: '🤖 Generated'),
      ]),
      const SizedBox(height: 4),
      const Text('Personalized based on your report',
          style: TextStyle(fontSize: 11, color: AppColors.textLight)),
      const SizedBox(height: 14),

      ..._meals.map((meal) {
        final icons = {'breakfast':'🌅','lunch':'☀️','snack':'🌿','dinner':'🌙'};
        final colors = {
          'breakfast': AppColors.mint, 'lunch': AppColors.peach,
          'snack': AppColors.lavender, 'dinner': const Color(0xFFE8F1FB),
        };
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors[meal.mealTime] ?? AppColors.cream,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(icons[meal.mealTime] ?? '🍽️',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(meal.mealTime.toUpperCase(),
                    style: const TextStyle(fontSize: 10,
                        color: AppColors.textLight, fontWeight: FontWeight.w700)),
                Text(meal.name, style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
              ])),
              Text('${meal.calories} kcal',
                  style: const TextStyle(fontSize: 11,
                      color: AppColors.textLight, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            Text('💡 ${meal.reason}', style: const TextStyle(
                fontSize: 11, color: AppColors.mintDeep, height: 1.4)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 4,
              children: meal.ingredients.map((i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(i, style: const TextStyle(
                    fontSize: 10, color: AppColors.textMid)),
              )).toList(),
            ),
          ]),
        );
      }),
    ]),
  );
}
