import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/health_controller.dart';
import '../models/health_models.dart';
import '../utils/app_theme.dart';
import '../widgets/date_filter_action.dart';

class HealthScreen extends GetView<HealthController> {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Readings'), actions: const [DateFilterAction()]),
      body: Obx(() {
        final records = controller.todayReadings;
        return records.isEmpty
            ? _buildEmpty()
            : ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: records.length,
                itemBuilder: (_, i) => _HealthTile(record: records[i]),
              );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppTheme.healthColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Reading', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp)),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_heart_rounded, size: 64.r, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text('No readings today', style: TextStyle(color: Colors.grey.shade500, fontSize: 16.sp)),
          SizedBox(height: 8.h),
          Text('Tap + to log BP, glucose, weight and more', style: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp)),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final selectedType = HealthReadingType.bp.obs;
    final valueCtrl = TextEditingController();
    final systolicCtrl = TextEditingController();
    final diastolicCtrl = TextEditingController();
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
                  Text('Log Health Reading', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  const Spacer(),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              SizedBox(height: 16.h),
              Obx(() => Wrap(
                spacing: 8.w, runSpacing: 8.h,
                children: HealthReadingType.values.map((type) => GestureDetector(
                  onTap: () => selectedType.value = type,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: selectedType.value == type ? AppTheme.healthColor : Colors.grey.shade100,
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
              Obx(() => selectedType.value == HealthReadingType.bp
                ? Row(
                    children: [
                      Expanded(child: TextField(controller: systolicCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Systolic', hintText: '120'))),
                      SizedBox(width: 12.w),
                      Expanded(child: TextField(controller: diastolicCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Diastolic', hintText: '80'))),
                    ],
                  )
                : TextField(
                    controller: valueCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${selectedType.value.label} (${selectedType.value.unit})',
                      hintText: 'Enter value',
                    ),
                  ),
              ),
              SizedBox(height: 12.h),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  final isBP = selectedType.value == HealthReadingType.bp;
                  if (isBP) {
                    if (systolicCtrl.text.isEmpty || diastolicCtrl.text.isEmpty) return;
                    controller.addHealthReading(
                      type: selectedType.value,
                      value: double.parse(systolicCtrl.text),
                      systolic: double.parse(systolicCtrl.text),
                      diastolic: double.parse(diastolicCtrl.text),
                      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                    );
                  } else {
                    if (valueCtrl.text.isEmpty) return;
                    controller.addHealthReading(
                      type: selectedType.value,
                      value: double.parse(valueCtrl.text),
                      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                    );
                  }
                  Get.back();
                  Get.snackbar('Saved!', '${selectedType.value.label} logged',
                    backgroundColor: AppTheme.healthColor, colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.healthColor),
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

class _HealthTile extends GetView<HealthController> {
  final HealthReading record;
  const _HealthTile({required this.record});

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
      onDismissed: (_) => controller.deleteHealthReading(record.id),
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
              decoration: BoxDecoration(color: AppTheme.healthColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(record.type.icon, color: AppTheme.healthColor, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.type.label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp, color: AppTheme.textDark)),
                Text(DateFormat('h:mm a').format(record.timestamp), style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
                if (record.notes != null && record.notes!.isNotEmpty)
                  Text(record.notes!, style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
              ],
            )),
            Text(record.displayValue, style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.healthColor, fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }
}
