import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/health_controller.dart';
import '../models/health_models.dart';
import '../utils/app_theme.dart';
import '../widgets/date_filter_action.dart';

class ExerciseScreen extends GetView<HealthController> {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise'), actions: const [DateFilterAction()]),
      body: Obx(() {
        final records = controller.todayExercise;
        return records.isEmpty
            ? _buildEmpty()
            : Column(
                children: [
                  const _ExerciseSummaryBar(),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: records.length,
                      itemBuilder: (_, i) => _ExerciseTile(record: records[i]),
                    ),
                  ),
                ],
              );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppTheme.exerciseColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Log Exercise', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp)),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center_rounded, size: 64.r, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text('No exercise logged today', style: TextStyle(color: Colors.grey.shade500, fontSize: 16.sp)),
          SizedBox(height: 8.h),
          Text('Tap + to log your workout', style: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp)),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final selectedType = ExerciseType.walk.obs;
    final durationCtrl = TextEditingController();
    final distanceCtrl = TextEditingController();
    final caloriesCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.only(
          left: 20.w, right: 20.w, top: 20.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Log Exercise', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  const Spacer(),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              SizedBox(height: 16.h),
              Obx(() => Wrap(
                spacing: 8.w, runSpacing: 8.h,
                children: ExerciseType.values.map((type) => GestureDetector(
                  onTap: () => selectedType.value = type,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: selectedType.value == type ? AppTheme.exerciseColor : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type.icon,
                          color: selectedType.value == type ? Colors.white : Colors.grey.shade500,
                          size: 16.r),
                        SizedBox(width: 6.w),
                        Text(type.label,
                          style: TextStyle(
                            fontSize: 12.sp, fontWeight: FontWeight.w600,
                            color: selectedType.value == type ? Colors.white : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              )),
              SizedBox(height: 16.h),
              TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (minutes) *', hintText: '30')),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: TextField(controller: distanceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Distance (km)', hintText: 'Optional'))),
                  SizedBox(width: 12.w),
                  Expanded(child: TextField(controller: caloriesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories burned', hintText: 'Optional'))),
                ],
              ),
              SizedBox(height: 12.h),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  if (durationCtrl.text.isEmpty) return;
                  controller.addExercise(
                    type: selectedType.value,
                    durationMinutes: int.parse(durationCtrl.text),
                    distanceKm: double.tryParse(distanceCtrl.text),
                    caloriesBurned: int.tryParse(caloriesCtrl.text),
                    notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  );
                  Get.back();
                  Get.snackbar('Great work!', '${selectedType.value.label} logged',
                    backgroundColor: AppTheme.exerciseColor, colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.exerciseColor),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _ExerciseSummaryBar extends GetView<HealthController> {
  const _ExerciseSummaryBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.exerciseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.exerciseColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(label: 'Total Time', value: '${controller.todayExerciseMinutes}', unit: 'min'),
          Container(height: 40.h, width: 1.w, color: AppTheme.exerciseColor.withValues(alpha: 0.2)),
          _SummaryItem(label: 'Burned', value: '${controller.todayCaloriesBurned}', unit: 'kcal'),
          Container(height: 40.h, width: 1.w, color: AppTheme.exerciseColor.withValues(alpha: 0.2)),
          _SummaryItem(label: 'Sessions', value: '${controller.todayExercise.length}', unit: 'total'),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value, unit;
  const _SummaryItem({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(text: TextSpan(
          children: [
            TextSpan(text: value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: AppTheme.exerciseColor)),
            TextSpan(text: ' $unit', style: TextStyle(fontSize: 12.sp, color: AppTheme.exerciseColor.withValues(alpha: 0.7))),
          ],
        )),
        Text(label, style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
      ],
    );
  }
}

class _ExerciseTile extends GetView<HealthController> {
  final ExerciseRecord record;
  const _ExerciseTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(14.r)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteExercise(record.id),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: AppTheme.exerciseColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(record.type.icon, color: AppTheme.exerciseColor, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.type.label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp, color: AppTheme.textDark)),
                SizedBox(height: 4.h),
                Row(children: [
                  Icon(Icons.timer_rounded, size: 12.r, color: Colors.grey.shade400),
                  SizedBox(width: 4.w),
                  Text('${record.durationMinutes} min', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
                  if (record.distanceKm != null) ...[
                    Text(' · ', style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp)),
                    Text('${record.distanceKm} km', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
                  ],
                  Text(' · ', style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp)),
                  Text(DateFormat('h:mm a').format(record.timestamp), style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
                ]),
              ],
            )),
            if (record.caloriesBurned != null)
              Text('${record.caloriesBurned} kcal', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.exerciseColor, fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }
}
