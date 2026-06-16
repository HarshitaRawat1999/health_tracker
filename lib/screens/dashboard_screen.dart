import 'package:health_tracker/app_exports.dart';

class DashboardScreen extends GetView<HealthController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tracker'),
        actions: const [DateFilterAction()],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _GreetingCard(),
            SizedBox(height: 16.h),
            const _StatsRow(),
            SizedBox(height: 20.h),
            _SectionHeader(
              title: 'Today\'s Food',
              icon: Icons.restaurant_rounded,
              color: AppTheme.foodColor,
              onViewAll: () => Get.find<NavigationController>().currentIndex.value = 1,
            ),
            SizedBox(height: 8.h),
            const _FoodSummary(),
            SizedBox(height: 20.h),
            _SectionHeader(
              title: 'Health Readings',
              icon: Icons.favorite_rounded,
              color: AppTheme.healthColor,
              onViewAll: () => Get.find<NavigationController>().currentIndex.value = 2,
            ),
            SizedBox(height: 8.h),
            const _HealthSummary(),
            SizedBox(height: 20.h),
            _SectionHeader(
              title: 'Exercise',
              icon: Icons.fitness_center_rounded,
              color: AppTheme.exerciseColor,
              onViewAll: () => Get.find<NavigationController>().currentIndex.value = 3,
            ),
            SizedBox(height: 8.h),
            const _ExerciseSummary(),
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends GetView<HealthController> {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                SizedBox(height: 4.h),
                Text('Track your health today',
                    style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 8.h),
                Obx(() => Text(
                  DateFormat('EEEE, MMMM d').format(controller.selectedDate.value),
                  style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                )),
              ],
            ),
          ),
          Icon(Icons.health_and_safety_rounded, color: Colors.white30, size: 60.r),
        ],
      ),
    );
  }
}

class _StatsRow extends GetView<HealthController> {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      children: [
        Expanded(child: _StatCard(
          label: 'Calories In', value: '${controller.todayCaloriesIn.toInt()}',
          unit: 'kcal', color: AppTheme.foodColor, icon: Icons.local_fire_department_rounded,
        )),
        SizedBox(width: 10.w),
        Expanded(child: _StatCard(
          label: 'Water',
          value: controller.todayWaterMl >= 1000
              ? (controller.todayWaterMl / 1000).toStringAsFixed(1)
              : '${controller.todayWaterMl.toInt()}',
          unit: controller.todayWaterMl >= 1000 ? 'L' : 'ml',
          color: AppTheme.waterColor, icon: Icons.water_drop_rounded,
        )),
        SizedBox(width: 10.w),
        Expanded(child: _StatCard(
          label: 'Exercise', value: '${controller.todayExerciseMinutes}',
          unit: 'min', color: AppTheme.exerciseColor, icon: Icons.timer_rounded,
        )),
      ],
    ));
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.unit, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20.r),
          SizedBox(height: 8.h),
          Text(value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: color)),
          Text(unit, style: TextStyle(fontSize: 11.sp, color: color.withValues(alpha: 0.7))),
          SizedBox(height: 2.h),
          Text(label, style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onViewAll;
  const _SectionHeader({required this.title, required this.icon, required this.color, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
          child: Icon(icon, color: color, size: 16.r),
        ),
        SizedBox(width: 8.w),
        Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const Spacer(),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Text('View all', style: TextStyle(fontSize: 12.sp, color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _FoodSummary extends GetView<HealthController> {
  const _FoodSummary();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.todayFood.isEmpty) return const _EmptyState(label: 'No food logged today');
      return Column(
        children: controller.todayFood.take(3).map((f) => _RecordTile(
          icon: f.type.icon,
          color: f.type == FoodType.water ? AppTheme.waterColor : AppTheme.foodColor,
          title: f.name,
          subtitle: f.type.label,
          trailing: f.type == FoodType.water
              ? '${f.waterMl?.toInt() ?? 0} ml'
              : f.calories != null ? '${f.calories!.toInt()} kcal' : '',
        )).toList(),
      );
    });
  }
}

class _HealthSummary extends GetView<HealthController> {
  const _HealthSummary();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.todayReadings.isEmpty) return const _EmptyState(label: 'No readings logged today');
      return Column(
        children: controller.todayReadings.take(3).map((r) => _RecordTile(
          icon: r.type.icon,
          color: AppTheme.healthColor,
          title: r.type.label,
          subtitle: DateFormat('MMM d, h:mm a').format(r.timestamp),
          trailing: r.displayValue,
        )).toList(),
      );
    });
  }
}

class _ExerciseSummary extends GetView<HealthController> {
  const _ExerciseSummary();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.todayExercise.isEmpty) return const _EmptyState(label: 'No exercise logged today');
      return Column(
        children: controller.todayExercise.take(3).map((e) => _RecordTile(
          icon: e.type.icon,
          color: AppTheme.exerciseColor,
          title: e.type.label,
          subtitle: '${e.durationMinutes} min',
          trailing: e.caloriesBurned != null ? '${e.caloriesBurned} kcal' : '',
        )).toList(),
      );
    });
  }
}

class _RecordTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle, trailing;
  const _RecordTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, color: color, size: 18.r),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: AppTheme.textDark)),
              Text(subtitle, style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
            ],
          )),
          if (trailing.isNotEmpty)
            Text(trailing, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp, color: color)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.add_circle_outline_rounded, color: Colors.grey.shade400, size: 20.r),
          SizedBox(width: 10.w),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp)),
        ],
      ),
    );
  }
}
