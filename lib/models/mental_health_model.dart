import 'package:cloud_firestore/cloud_firestore.dart';

class MentalHealth {
  final String id;
  final String patientId;
  final int moodRating;
  final int stressLevel;
  final int sleepQuality;
  final int socialEngagement;
  final DateTime dateRecorded;
  final String alertStatus;

  MentalHealth({
    required this.id,
    required this.patientId,
    required this.moodRating,
    required this.stressLevel,
    required this.sleepQuality,
    required this.socialEngagement,
    required this.dateRecorded,
    required this.alertStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'moodRating': moodRating,
      'stressLevel': stressLevel,
      'sleepQuality': sleepQuality,
      'socialEngagement': socialEngagement,
      'dateRecorded': dateRecorded,
      'alertStatus': alertStatus,
    };
  }

  factory MentalHealth.fromMap(String id, Map<String, dynamic> map) {
    return MentalHealth(
      id: id,
      patientId: map['patientId'],
      moodRating: map['moodRating'],
      stressLevel: map['stressLevel'],
      sleepQuality: map['sleepQuality'],
      socialEngagement: map['socialEngagement'],
      dateRecorded: (map['dateRecorded'] as Timestamp).toDate(),
      alertStatus: map['alertStatus'],
    );
  }
}
