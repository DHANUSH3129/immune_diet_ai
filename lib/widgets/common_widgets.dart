import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// ── Gradient Button ──────────────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool loading;
  const GradientButton(
      {super.key, required this.text, this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.mintDark, AppColors.lavenderDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.lavenderDark.withOpacity(0.3),
                blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text(text,
                  style: const TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

// ── Tag Chip ─────────────────────────────────────────────────────────────
class TagChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const TagChip(
      {super.key, required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
  );
}

TagChip mintTag(String label) =>
    TagChip(label: label, bg: AppColors.mint, fg: AppColors.mintDeep);
TagChip peachTag(String label) =>
    TagChip(label: label, bg: AppColors.peach, fg: AppColors.peachDark);
TagChip lavTag(String label) =>
    TagChip(label: label, bg: AppColors.lavender, fg: AppColors.lavenderDark);

// ── Section Header ────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(
      {super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title,
          style: Theme.of(context).textTheme.headlineMedium),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: AppColors.mintDark)),
        ),
    ],
  );
}

// ── Nutrient Bar ──────────────────────────────────────────────────────────
class NutrientBar extends StatelessWidget {
  final String emoji;
  final String name;
  final double percent;
  final String value;
  final List<Color> colors;
  const NutrientBar({super.key,
    required this.emoji, required this.name,
    required this.percent, required this.value,
    required this.colors});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 10),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFF0EAF8),
              valueColor: AlwaysStoppedAnimation(colors.first),
            ),
          ),
        ],
      )),
      const SizedBox(width: 10),
      Text(value,
          style: const TextStyle(fontSize: 11,
              fontWeight: FontWeight.w600, color: AppColors.textLight)),
    ],
  );
}

// ── Firebase Badge ────────────────────────────────────────────────────────
class FirebaseBadge extends StatelessWidget {
  final String label;
  const FirebaseBadge({super.key, this.label = '🔥 Synced'});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(10)),
    child: Text(label,
        style: const TextStyle(fontSize: 10,
            fontWeight: FontWeight.w700, color: AppColors.mintDeep)),
  );
}

// ── Macro Chip ────────────────────────────────────────────────────────────
class MacroChip extends StatelessWidget {
  final String value;
  final String label;
  const MacroChip({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(value, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(
            fontSize: 10, color: AppColors.textLight)),
      ]),
    ),
  );
}
