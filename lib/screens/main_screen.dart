import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'meal_plan_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    MealPlanScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _index, children: _screens),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F4).withOpacity(0.95),
        border: const Border(
            top: BorderSide(color: Color(0x33B4A0C8), width: 1)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _navItem(1, Icons.restaurant_rounded,
                  Icons.restaurant_outlined, 'Meals'),
              _navItem(2, Icons.chat_bubble_rounded,
                  Icons.chat_bubble_outline_rounded, 'AI Coach'),
              _navItem(3, Icons.person_rounded,
                  Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _navItem(int idx, IconData active, IconData inactive, String label) {
    final isActive = _index == idx;
    return GestureDetector(
      onTap: () => setState(() => _index = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.lavender : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isActive ? active : inactive,
              size: 24,
              color: isActive
                  ? AppColors.lavenderDark : AppColors.textLight),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: isActive
                  ? AppColors.lavenderDark : AppColors.textLight)),
        ]),
      ),
    );
  }
}
