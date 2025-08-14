import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String patientId;
  final String doctorId;
  final String medName;
  final String dosage;
  final List<String> frequency; // e.g., ["Morning", "Evening"]
  final DateTime startDate;
  final DateTime endDate;
  final String medStatus; // "Current" or "Past"

  Medication({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.medName,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.medStatus,
  });

factory Medication.fromMap(String id, Map<String, dynamic> data) {
  return Medication(
    id: id,
    patientId: data['patientId'] ?? data['Patient_ID'] ?? '',
    doctorId: data['doctorId'] ?? data['Doctor_ID'] ?? '',
    medName: data['medName'] ?? data['Med_Name'] ?? '',
    dosage: data['dosage'] ?? data['Dosage'] ?? '',
    frequency: List<String>.from(data['frequency'] ?? data['Frequency'] ?? []),
    startDate: (data['startDate'] ?? data['StartDate'] as Timestamp).toDate(),
    endDate: (data['endDate'] ?? data['EndDate'] as Timestamp).toDate(),
    medStatus: data['medStatus'] ?? data['Med_status'] ?? 'Current',
  );
}
  
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'medName': medName,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'medStatus': medStatus,
    };
  }
}