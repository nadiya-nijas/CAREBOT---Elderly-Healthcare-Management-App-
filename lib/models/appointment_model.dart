import 'package:cloud_firestore/cloud_firestore.dart';
class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime apptDate;
  final String apptType;
  final String apptStatus;
  final String timeSlot;
  final String createdBy;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.apptDate,
    required this.apptType,
    required this.apptStatus,
    required this.timeSlot,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() => {
    'patientId': patientId,
    'doctorId': doctorId,
    'apptDate': apptDate,
    'apptType': apptType,
    'apptStatus': apptStatus,
    'timeSlot': timeSlot,
    'createdBy': createdBy,
  };

  factory Appointment.fromMap(String id, Map<String, dynamic> data) {
  return Appointment(
    id: id,
    patientId: data['patientId'] ?? '',
    doctorId: data['doctorId'] ?? '',
    apptDate: (data['apptDate'] as Timestamp).toDate(),
    apptType: data['apptType'] ?? '',
    apptStatus: data['apptStatus'] ?? '',
    timeSlot: data['timeSlot'] ?? '',
    createdBy: data['createdBy'] ?? '',
  );
}
}