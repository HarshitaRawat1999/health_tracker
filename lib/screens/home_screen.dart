import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/health_controller.dart';
import '../utils/app_theme.dart';
import 'dashboard_screen.dart';
import 'food_screen.dart';
import 'health_screen.dart';
import 'exercise_screen.dart';

class HomeScreen extends GetView<HealthController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      const FoodScreen(),
      const HealthScreen(),
      const ExerciseScreen(),
    ];

    return Obx(() => Scaffold(
      body: screens[controller.currentIndex.value],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(index: 0, icon: Icons.dashboard_rounded, label: 'Dashboard'),
                _NavItem(index: 1, icon: Icons.restaurant_rounded, label: 'Food'),
                _NavItem(index: 2, icon: Icons.favorite_rounded, label: 'Health'),
                _NavItem(index: 3, icon: Icons.fitness_center_rounded, label: 'Exercise'),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class _NavItem extends GetView<HealthController> {
  final int index;
  final IconData icon;
  final String label;

  const _NavItem({required this.index, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      return GestureDetector(
        onTap: () => controller.currentIndex.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? AppTheme.primary : Colors.grey.shade400, size: 22.r),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppTheme.primary : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
