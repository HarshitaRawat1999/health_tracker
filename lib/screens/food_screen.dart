import 'package:health_tracker/app_exports.dart';

class FoodScreen extends GetView<HealthController> {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food & Water'), actions: const [DateFilterAction()]),
      body: Obx(() {
        final records = controller.todayFood;
        return records.isEmpty
            ? _buildEmpty()
            : ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: records.length,
                itemBuilder: (_, i) => _FoodTile(record: records[i]),
              );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Log Food', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp)),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_rounded, size: 64.r, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text('No food logged today', style: TextStyle(color: Colors.grey.shade500, fontSize: 16.sp)),
          SizedBox(height: 8.h),
          Text('Tap + to add your meals and water', style: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp)),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) async {
    final message = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FoodLogSheet(controller: controller),
    );
    if (message != null) {
      Get.snackbar('Added!', message,
        backgroundColor: AppTheme.primary, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
    }
  }
}

class _FoodLogSheet extends StatefulWidget {
  final HealthController controller;
  const _FoodLogSheet({required this.controller});
  @override
  State<_FoodLogSheet> createState() => _FoodLogSheetState();
}

class _FoodLogSheetState extends State<_FoodLogSheet> {
  final formKey     = GlobalKey<FormState>();
  final nameCtrl    = TextEditingController();
  final calCtrl     = TextEditingController();
  final waterCtrl   = TextEditingController();
  final notesCtrl   = TextEditingController();
  final selectedType = FoodType.breakfast.obs;

  @override
  void dispose() {
    nameCtrl.dispose();
    calCtrl.dispose();
    waterCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w, right: 20.w, top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Log Food / Water', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              SizedBox(height: 16.h),
              Obx(() => Wrap(
                spacing: 8.w, runSpacing: 8.h,
                children: FoodType.values.map((type) => GestureDetector(
                  onTap: () => selectedType.value = type,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: selectedType.value == type
                          ? (type == FoodType.water ? AppTheme.waterColor : AppTheme.foodColor)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type.icon,
                          color: selectedType.value == type ? Colors.white : Colors.grey.shade500,
                          size: 18.r),
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
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name / Description *', hintText: 'e.g. Oatmeal with banana'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              SizedBox(height: 12.h),
              Obx(() => selectedType.value == FoodType.water
                ? TextField(controller: waterCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (ml)', hintText: '250'))
                : TextField(controller: calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories (kcal)', hintText: 'Optional')),
              ),
              SizedBox(height: 12.h),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 2),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final name = nameCtrl.text.trim();
                  widget.controller.addFood(
                    type: selectedType.value,
                    name: name,
                    calories: double.tryParse(calCtrl.text),
                    waterMl: double.tryParse(waterCtrl.text),
                    notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  );
                  Navigator.pop(context, '$name logged successfully');
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodTile extends GetView<HealthController> {
  final FoodRecord record;
  const _FoodTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = record.type == FoodType.water ? AppTheme.waterColor : AppTheme.foodColor;
    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(14.r)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteFood(record.id),
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
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(record.type.icon, color: color, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp, color: AppTheme.textDark)),
                SizedBox(height: 2.h),
                Row(children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
                    child: Text(record.type.label, style: TextStyle(fontSize: 11.sp, color: color, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(width: 8.w),
                  Text(DateFormat('MMM d, h:mm a').format(record.timestamp), style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
                ]),
              ],
            )),
            if (record.type == FoodType.water && record.waterMl != null)
              Text('${record.waterMl!.toInt()} ml', style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14.sp))
            else if (record.calories != null)
              Text('${record.calories!.toInt()} kcal', style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }
}
