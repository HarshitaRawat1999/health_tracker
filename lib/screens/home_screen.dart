import 'package:health_tracker/app_exports.dart';

class HomeScreen extends GetView<NavigationController> {
  const HomeScreen({super.key});

  // Static const preserves widget identity across tab switches so
  // IndexedStack can keep each screen mounted and retain scroll state.
  static const _screens = [
    DashboardScreen(),
    FoodScreen(),
    HealthScreen(),
    ExerciseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final hc = Get.find<HealthController>();
    return Obx(() {
      if (hc.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        );
      }
      return Scaffold(
        body: Column(
          children: [
            Obx(() {
              final err = hc.loadError.value;
              if (err == null) return const SizedBox.shrink();
              return _ErrorBanner(message: err, onDismiss: () => hc.loadError.value = null);
            }),
            Expanded(
              child: Obx(() => IndexedStack(
                index: controller.currentIndex.value,
                children: _screens,
              )),
            ),
          ],
        ),
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
                  _NavItem(index: 0, icon: Icons.dashboard_rounded,    label: 'Dashboard'),
                  _NavItem(index: 1, icon: Icons.restaurant_rounded,   label: 'Food'),
                  _NavItem(index: 2, icon: Icons.favorite_rounded,     label: 'Health'),
                  _NavItem(index: 3, icon: Icons.fitness_center_rounded, label: 'Exercise'),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _NavItem extends GetView<NavigationController> {
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

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.shade50,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 18.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 12.sp, color: Colors.red.shade700)),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close_rounded, size: 18.r, color: Colors.red.shade400),
          ),
        ],
      ),
    );
  }
}
