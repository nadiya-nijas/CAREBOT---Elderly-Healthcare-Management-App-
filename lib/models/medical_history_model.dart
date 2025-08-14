import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalHistory {
  final String id;
  final String bloodType;
  final String allergies;
  final String chronicDisease;
  // final String diagnosis;
  final DateTime visitDate;
  final String doctorId;
  // final List<String> medications;
  final String notes;

  MedicalHistory({
    required this.id,
    required this.bloodType,
    required this.allergies,
    required this.chronicDisease,
    // required this.diagnosis,
    required this.visitDate,
    required this.doctorId,
    // required this.medications,
    required this.notes,
  });

  factory MedicalHistory.fromMap(String id, Map<String, dynamic> data) {
    return MedicalHistory(
      id: id,
      bloodType: data['bloodType'] ?? '',
      allergies: data['allergies'] ?? '',
      chronicDisease: data['chronicDisease'] ?? '',
      // diagnosis: data['diagnosis'] ?? '',
      visitDate: (data['visitDate'] as Timestamp).toDate(),
      doctorId: data['doctorId'] ?? '',
      // medications: List<String>.from(data['medications'] ?? []),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bloodType': bloodType,
      'allergies': allergies,
      'chronicDisease': chronicDisease,
      // 'diagnosis': diagnosis,
      'visitDate': Timestamp.fromDate(visitDate),
      'doctorId': doctorId,
      // 'medications': medications,
      'notes': notes,
    };
  }
}

