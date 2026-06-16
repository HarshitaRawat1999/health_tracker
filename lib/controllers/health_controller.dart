import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/health_models.dart';

class HealthController extends GetxController {
  static HealthController get to => Get.find();

  final _uuid = const Uuid();

  final foodRecords = <FoodRecord>[].obs;
  final healthReadings = <HealthReading>[].obs;
  final exerciseRecords = <ExerciseRecord>[].obs;

  final selectedDate = DateTime.now().obs;
  final isLoading = false.obs;
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // ── Date helpers ─────────────────────────────────────────────────────────────
  void setDate(DateTime date) => selectedDate.value = date;

  List<FoodRecord> get todayFood => foodRecords
      .where((r) => _isSameDay(r.timestamp, selectedDate.value))
      .toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<HealthReading> get todayReadings => healthReadings
      .where((r) => _isSameDay(r.timestamp, selectedDate.value))
      .toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<ExerciseRecord> get todayExercise => exerciseRecords
      .where((r) => _isSameDay(r.timestamp, selectedDate.value))
      .toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Summary stats ─────────────────────────────────────────────────────────────
  double get todayCaloriesIn => todayFood
      .where((f) => f.type != FoodType.water)
      .fold(0, (s, f) => s + (f.calories ?? 0));

  double get todayWaterMl => todayFood
      .where((f) => f.type == FoodType.water)
      .fold(0, (s, f) => s + (f.waterMl ?? 0));

  int get todayExerciseMinutes =>
      todayExercise.fold(0, (s, e) => s + e.durationMinutes);

  int get todayCaloriesBurned =>
      todayExercise.fold(0, (s, e) => s + (e.caloriesBurned ?? 0));

  // ── CRUD: Food ────────────────────────────────────────────────────────────────
  Future<void> addFood({
    required FoodType type,
    required String name,
    double? calories,
    double? waterMl,
    String? notes,
  }) async {
    final record = FoodRecord(
      id: _uuid.v4(),
      type: type,
      name: name,
      calories: calories,
      waterMl: waterMl,
      timestamp: DateTime.now(),
      notes: notes,
    );
    foodRecords.add(record);
    await _saveData();
  }

  Future<void> deleteFood(String id) async {
    foodRecords.removeWhere((r) => r.id == id);
    await _saveData();
  }

  // ── CRUD: Health Reading ──────────────────────────────────────────────────────
  Future<void> addHealthReading({
    required HealthReadingType type,
    required double value,
    double? systolic,
    double? diastolic,
    String? notes,
  }) async {
    final record = HealthReading(
      id: _uuid.v4(),
      type: type,
      value: value,
      systolic: systolic,
      diastolic: diastolic,
      timestamp: DateTime.now(),
      notes: notes,
    );
    healthReadings.add(record);
    await _saveData();
  }

  Future<void> deleteHealthReading(String id) async {
    healthReadings.removeWhere((r) => r.id == id);
    await _saveData();
  }

  // ── CRUD: Exercise ────────────────────────────────────────────────────────────
  Future<void> addExercise({
    required ExerciseType type,
    required int durationMinutes,
    double? distanceKm,
    int? caloriesBurned,
    String? notes,
  }) async {
    final record = ExerciseRecord(
      id: _uuid.v4(),
      type: type,
      durationMinutes: durationMinutes,
      distanceKm: distanceKm,
      caloriesBurned: caloriesBurned,
      timestamp: DateTime.now(),
      notes: notes,
    );
    exerciseRecords.add(record);
    await _saveData();
  }

  Future<void> deleteExercise(String id) async {
    exerciseRecords.removeWhere((r) => r.id == id);
    await _saveData();
  }

  // ── Persistence ───────────────────────────────────────────────────────────────
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('food', jsonEncode(foodRecords.map((r) => r.toJson()).toList()));
    prefs.setString('health', jsonEncode(healthReadings.map((r) => r.toJson()).toList()));
    prefs.setString('exercise', jsonEncode(exerciseRecords.map((r) => r.toJson()).toList()));
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final foodJson = prefs.getString('food');
      final healthJson = prefs.getString('health');
      final exerciseJson = prefs.getString('exercise');

      if (foodJson != null) {
        foodRecords.value = (jsonDecode(foodJson) as List)
            .map((j) => FoodRecord.fromJson(j))
            .toList();
      }
      if (healthJson != null) {
        healthReadings.value = (jsonDecode(healthJson) as List)
            .map((j) => HealthReading.fromJson(j))
            .toList();
      }
      if (exerciseJson != null) {
        exerciseRecords.value = (jsonDecode(exerciseJson) as List)
            .map((j) => ExerciseRecord.fromJson(j))
            .toList();
      }
    } catch (_) {}
    isLoading.value = false;
  }
}
