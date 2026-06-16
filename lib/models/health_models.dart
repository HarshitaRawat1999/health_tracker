import 'package:flutter/material.dart';

// ── Food ──────────────────────────────────────────────────────────────────────
enum FoodType { breakfast, lunch, snack, water, dinner }

extension FoodTypeExt on FoodType {
  String get label {
    switch (this) {
      case FoodType.breakfast: return 'Breakfast';
      case FoodType.lunch:     return 'Lunch';
      case FoodType.snack:     return 'Snack';
      case FoodType.water:     return 'Water';
      case FoodType.dinner:    return 'Dinner';
    }
  }

  IconData get icon {
    switch (this) {
      case FoodType.breakfast: return Icons.free_breakfast_rounded;
      case FoodType.lunch:     return Icons.lunch_dining_rounded;
      case FoodType.snack:     return Icons.cookie_rounded;
      case FoodType.water:     return Icons.water_drop_rounded;
      case FoodType.dinner:    return Icons.dinner_dining_rounded;
    }
  }
}

class FoodRecord {
  final String id;
  final FoodType type;
  final String name;
  final double? calories;
  final double? waterMl;
  final DateTime timestamp;
  final String? notes;

  FoodRecord({
    required this.id,
    required this.type,
    required this.name,
    this.calories,
    this.waterMl,
    required this.timestamp,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type.name, 'name': name,
    'calories': calories, 'waterMl': waterMl,
    'timestamp': timestamp.toIso8601String(), 'notes': notes,
  };

  factory FoodRecord.fromJson(Map<String, dynamic> j) => FoodRecord(
    id: j['id'],
    // legacy records stored type as int index; new records store name string
    type: j['type'] is int
        ? FoodType.values[j['type'] as int]
        : FoodType.values.byName(j['type'] as String),
    name: j['name'],
    calories: j['calories']?.toDouble(),
    waterMl: j['waterMl']?.toDouble(),
    timestamp: DateTime.parse(j['timestamp']),
    notes: j['notes'],
  );
}

// ── Health Reading ─────────────────────────────────────────────────────────────
enum HealthReadingType { bp, glucose, weight, temperature, oxygen }

extension HealthReadingTypeExt on HealthReadingType {
  String get label {
    switch (this) {
      case HealthReadingType.bp:          return 'Blood Pressure';
      case HealthReadingType.glucose:     return 'Glucose';
      case HealthReadingType.weight:      return 'Weight';
      case HealthReadingType.temperature: return 'Temperature';
      case HealthReadingType.oxygen:      return 'Oxygen';
    }
  }

  String get unit {
    switch (this) {
      case HealthReadingType.bp:          return 'mmHg';
      case HealthReadingType.glucose:     return 'mg/dL';
      case HealthReadingType.weight:      return 'kg';
      case HealthReadingType.temperature: return '°C';
      case HealthReadingType.oxygen:      return '%';
    }
  }

  IconData get icon {
    switch (this) {
      case HealthReadingType.bp:          return Icons.favorite_rounded;
      case HealthReadingType.glucose:     return Icons.bloodtype_rounded;
      case HealthReadingType.weight:      return Icons.monitor_weight_rounded;
      case HealthReadingType.temperature: return Icons.thermostat_rounded;
      case HealthReadingType.oxygen:      return Icons.air_rounded;
    }
  }
}

class HealthReading {
  final String id;
  final HealthReadingType type;
  final double value;
  final double? systolic;
  final double? diastolic;
  final DateTime timestamp;
  final String? notes;

  HealthReading({
    required this.id,
    required this.type,
    required this.value,
    this.systolic,
    this.diastolic,
    required this.timestamp,
    this.notes,
  });

  String get displayValue {
    if (type == HealthReadingType.bp && systolic != null && diastolic != null) {
      return '${systolic!.toInt()}/${diastolic!.toInt()} ${type.unit}';
    }
    return '${value % 1 == 0 ? value.toInt() : value} ${type.unit}';
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type.name, 'value': value,
    'systolic': systolic, 'diastolic': diastolic,
    'timestamp': timestamp.toIso8601String(), 'notes': notes,
  };

  factory HealthReading.fromJson(Map<String, dynamic> j) => HealthReading(
    id: j['id'],
    type: j['type'] is int
        ? HealthReadingType.values[j['type'] as int]
        : HealthReadingType.values.byName(j['type'] as String),
    value: j['value'].toDouble(),
    systolic: j['systolic']?.toDouble(),
    diastolic: j['diastolic']?.toDouble(),
    timestamp: DateTime.parse(j['timestamp']),
    notes: j['notes'],
  );
}

// ── Exercise ───────────────────────────────────────────────────────────────────
enum ExerciseType { walk, run, yoga, cycling, gym, swimming, other }

extension ExerciseTypeExt on ExerciseType {
  String get label {
    switch (this) {
      case ExerciseType.walk:     return 'Walk';
      case ExerciseType.run:      return 'Run';
      case ExerciseType.yoga:     return 'Yoga';
      case ExerciseType.cycling:  return 'Cycling';
      case ExerciseType.gym:      return 'Gym';
      case ExerciseType.swimming: return 'Swimming';
      case ExerciseType.other:    return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExerciseType.walk:     return Icons.directions_walk_rounded;
      case ExerciseType.run:      return Icons.directions_run_rounded;
      case ExerciseType.yoga:     return Icons.self_improvement_rounded;
      case ExerciseType.cycling:  return Icons.directions_bike_rounded;
      case ExerciseType.gym:      return Icons.fitness_center_rounded;
      case ExerciseType.swimming: return Icons.pool_rounded;
      case ExerciseType.other:    return Icons.sports_rounded;
    }
  }
}

class ExerciseRecord {
  final String id;
  final ExerciseType type;
  final int durationMinutes;
  final double? distanceKm;
  final int? caloriesBurned;
  final DateTime timestamp;
  final String? notes;

  ExerciseRecord({
    required this.id,
    required this.type,
    required this.durationMinutes,
    this.distanceKm,
    this.caloriesBurned,
    required this.timestamp,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type.name, 'durationMinutes': durationMinutes,
    'distanceKm': distanceKm, 'caloriesBurned': caloriesBurned,
    'timestamp': timestamp.toIso8601String(), 'notes': notes,
  };

  factory ExerciseRecord.fromJson(Map<String, dynamic> j) => ExerciseRecord(
    id: j['id'],
    type: j['type'] is int
        ? ExerciseType.values[j['type'] as int]
        : ExerciseType.values.byName(j['type'] as String),
    durationMinutes: j['durationMinutes'],
    distanceKm: j['distanceKm']?.toDouble(),
    caloriesBurned: j['caloriesBurned'],
    timestamp: DateTime.parse(j['timestamp']),
    notes: j['notes'],
  );
}
