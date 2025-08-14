import 'package:cloud_firestore/cloud_firestore.dart';

class HealthMetric {
  final String id;
  final double height;
  final double weight;
  final double temperature;
  final String bloodPressure;
  final int heartRate;
  final double o2Saturation;
  final double bloodSugarLevel;
  final DateTime dateRecorded;

  HealthMetric({
    required this.id,
    required this.height,
    required this.weight,
    required this.temperature,
    required this.bloodPressure,
    required this.heartRate,
    required this.o2Saturation,
    required this.bloodSugarLevel,
    required this.dateRecorded,
  });

  factory HealthMetric.fromMap(String id, Map<String, dynamic> data) {
    return HealthMetric(
      id: id,
      height: (data['height'] ?? 0).toDouble(),
      weight: (data['weight'] ?? 0).toDouble(),
      temperature: (data['temperature'] ?? 0).toDouble(),
      bloodPressure: data['bloodPressure'] ?? 'N/A',
      heartRate: (data['heartRate'] ?? 0).toInt(),
      o2Saturation: (data['o2Saturation'] ?? 0).toDouble(),
      bloodSugarLevel: (data['bloodSugarLevel'] ?? 0).toDouble(),
      dateRecorded: (data['dateRecorded'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'weight': weight,
      'temperature': temperature,
      'bloodPressure': bloodPressure,
      'heartRate': heartRate,
      'o2Saturation': o2Saturation,
      'bloodSugarLevel': bloodSugarLevel,
      'dateRecorded': dateRecorded,
    };
  }
}
