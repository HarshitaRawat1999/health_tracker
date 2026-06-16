import 'package:health_tracker/app_exports.dart';

class DateFilterAction extends GetView<HealthController> {
  const DateFilterAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: Obx(() => GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: controller.selectedDate.value,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null) controller.setDate(picked);
        },
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16.r, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              DateFormat('MMM d').format(controller.selectedDate.value),
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: Colors.white),
            ),
          ],
        ),
      )),
    );
  }
}
