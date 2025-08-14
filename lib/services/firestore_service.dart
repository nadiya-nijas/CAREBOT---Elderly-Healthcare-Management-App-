import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/medical_history_model.dart';
import '../models/health_metrics_model.dart';
import '../models/mental_health_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== USER ==========

  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      throw Exception('User not found');
    }
  }

  Future<void> createUserAndHandleRole(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());

    if (user.role == 'doctor') {
      await _db.collection('doctors').doc(user.uid).set({
        'uid': user.uid,
        'name': user.name,
        'email': user.email,
        'specialization': '',
        'phone': '',
        'createdAt': Timestamp.now(),
      });
    }
  }

  // ========== DOCTOR-PATIENT LINK ==========

  Future<void> createDoctorPatientLink({
    required String doctorId,
    required String patientId,
  }) async {
    String linkId = "${doctorId}_$patientId";
    final docRef = _db.collection('doctor_patient').doc(linkId);

    final data = {
      'doctorId': doctorId,
      'patientId': patientId,
      'linked_at': FieldValue.serverTimestamp(),
    };

    try {
      await docRef.set(data);
      print("Doctor-Patient link created successfully");
    } catch (e) {
      print("Error creating doctor-patient link: $e");
    }
  }

  // ========== MEDICAL HISTORY ==========

  Stream<QuerySnapshot> getMedicalHistory(String patientId) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('medicalHistory')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<List<MedicalHistory>> getMedicalHistoryForPatient(String patientId) async {
    final snapshot = await _db
        .collection('patients')
        .doc(patientId)
        .collection('medicalHistory')
        .orderBy('visitDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MedicalHistory.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addMedicalHistory(String patientId, Map<String, dynamic> data) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('medicalHistory')
        .add(data);
  }

  Future<void> addMedicalHistoryWithModel(String patientId, MedicalHistory history) async {
    await _db.collection('patients')
        .doc(patientId)
        .collection('medicalHistory')
        .add({
          'bloodType': history.bloodType,
          'allergies': history.allergies,
          'chronicDisease': history.chronicDisease,
          'visitDate': Timestamp.fromDate(history.visitDate),
          'doctorId': history.doctorId,
          'notes': history.notes,
        });
  }

  Future<void> updateMedicalHistory(String patientId, String historyId, Map<String, dynamic> data) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('medicalHistory')
        .doc(historyId)
        .update(data);
  }

  Future<void> updateMedicalHistoryWithModel(String patientId, String historyId, MedicalHistory history) async {
    await _db.collection('patients')
        .doc(patientId)
        .collection('medicalHistory')
        .doc(historyId)
        .update({
          'bloodType': history.bloodType,
          'allergies': history.allergies,
          'chronicDisease': history.chronicDisease,
          'visitDate': Timestamp.fromDate(history.visitDate),
          'doctorId': history.doctorId,
          'notes': history.notes,
        });
  }

    Future<List<Map<String, dynamic>>> getMedicalHistoryOnce(String patientId) async {
    final snapshot = await _db
        .collection('patients')
        .doc(patientId)
        .collection('medicalHistory')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // ========== MEDICATION CRUD ==========

  Stream<QuerySnapshot> getMedications(String patientId) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('medications')
        .orderBy('startDate', descending: true)
        .snapshots();
  }

  Future<void> addMedication(String patientId, Map<String, dynamic> data) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('medications')
        .add(data);
  }

  Future<void> updateMedication(String patientId, String medId, Map<String, dynamic> data) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('medications')
        .doc(medId)
        .update(data);
  }

  Future<List<Map<String, dynamic>>> getMedicationsOnce(String patientId) async {
    final snapshot = await _db.collection('patients').doc(patientId).collection('medications').get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  // ========== HEALTH METRICS ==========

  Stream<QuerySnapshot> getHealthMetrics(String patientId) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('healthMetrics')
        .orderBy('dateRecorded', descending: true)
        .snapshots();
  }

  Future<List<HealthMetric>> getHealthMetricsForPatient(String patientId) async {
    final snapshot = await _db
        .collection('patients')
        .doc(patientId)
        .collection('healthMetrics')
        .orderBy('dateRecorded', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HealthMetric.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addHealthMetrics(String patientId, HealthMetric metrics) async {
    await _db.collection('patients')
        .doc(patientId)
        .collection('healthMetrics')
        .add(metrics.toMap());
  }

  Future<void> updateHealthMetrics(String patientId, String metricId, HealthMetric metrics) async {
    await _db.collection('patients')
        .doc(patientId)
        .collection('healthMetrics')
        .doc(metricId)
        .update(metrics.toMap());
  }

  Future<List<Map<String, dynamic>>> getHealthMetricsOnce(String patientId) async {
    final snapshot = await _db.collection('patients').doc(patientId).collection('healthMetrics').get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  // ========== APPOINTMENTS (Read-only) ==========

  Stream<QuerySnapshot> getAppointments(String patientId) {
  return _db
      .collection('appointments')
      .where('patientId', isEqualTo: patientId)
      .orderBy('apptDate', descending: true) // <-- CORRECT
      .snapshots();
}

  // ========== MENTAL HEALTH ==========

  Stream<QuerySnapshot> getMentalHealthRecords(String patientId) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('mentalHealth')
        .orderBy('MH_date_recorded', descending: true)
        .snapshots();
  }

  Future<void> addMentalHealth(MentalHealth mh) async {
    await _db
        .collection('patients')
        .doc(mh.patientId)
        .collection('mentalHealth')
        .add(mh.toMap());
  }

  Future<void> updateMentalHealth(String patientId, String mhId, MentalHealth mh) async {
    await _db
        .collection('patients')
        .doc(patientId)
        .collection('mentalHealth')
        .doc(mhId)
        .update(mh.toMap());
  }

  Stream<MentalHealth?> getLatestMentalHealth(String patientId) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('mentalHealth')
        .orderBy('dateRecorded', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return MentalHealth.fromMap(doc.id, doc.data());
        });
  }

  Future<void> checkAndAddSampleMentalHealthIfNone(String patientId) async {
    final snapshot = await _db
        .collection('patients')
        .doc(patientId)
        .collection('mentalHealth')
        .get();

    if (snapshot.docs.isEmpty) {
      await _db
          .collection('patients')
          .doc(patientId)
          .collection('mentalHealth')
          .add({
        'patientId': patientId,
        'moodRating': 5,
        'stressLevel': 5,
        'sleepQuality': 5,
        'socialEngagement': 5,
        'dateRecorded': Timestamp.now(),
        'alertStatus': 'Normal',
      });
    }
  }

  // ========== FETCH FULL PATIENT DATA BY EMAIL ==========

  Future<Map<String, dynamic>> fetchPatientFullDataByUid(String uid) async {
  final patientDoc = await _db.collection('patients').doc(uid).get();
  if (!patientDoc.exists) {
    throw Exception('Patient not found');
  }
  final patientId = patientDoc.id;

  final medicalHistorySnap = await _db
      .collection('patients')
      .doc(patientId)
      .collection('medicalHistory')
      .get();

  final medicationsSnap = await _db
      .collection('patients')
      .doc(patientId)
      .collection('medications')
      .get();

  final healthMetricsSnap = await _db
      .collection('patients')
      .doc(patientId)
      .collection('healthMetrics')
      .get();

  final appointmentsSnap = await _db
      .collection('patients')
      .doc(patientId)
      .collection('appointments')
      .get();

  final mentalHealthSnap = await _db
      .collection('patients')
      .doc(patientId)
      .collection('mentalHealth')
      .get();

  return {
    'patientDoc': patientDoc.data(),
    'medicalHistory': medicalHistorySnap.docs.map((d) => d.data()).toList(),
    'medications': medicationsSnap.docs.map((d) => d.data()).toList(),
    'healthMetrics': healthMetricsSnap.docs.map((d) => d.data()).toList(),
    'appointments': appointmentsSnap.docs.map((d) => d.data()).toList(),
    'mentalHealth': mentalHealthSnap.docs.map((d) => d.data()).toList(),
  };
}

Future<List<Map<String, dynamic>>> getMentalHealthOnce(String patientId) async {
    final snapshot = await _db
        .collection('patients')
        .doc(patientId)
        .collection('mentalHealth')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getAppointmentsOnce(String patientId) async {
    final snapshot = await _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
  // ========== OTHER HELPERS ==========

  Future<DocumentSnapshot> getPatientDocument(String patientId) {
    return _db.collection('patients').doc(patientId).get();
  }
Future<void> assignPatientToGuardian({
  required String guardianId,
  required String patientUid,
  required String patientEmail,
}) async {
  // Fetch patient name from users collection
  final userDoc = await _db.collection('users').doc(patientUid).get();
  String name = '';
  if (userDoc.exists) {
    name = userDoc.data()?['name'] ?? '';
  }

  final patientData = {
    'uid': patientUid,
    'email': patientEmail,
    'name': name,
    'assignedAt': FieldValue.serverTimestamp(),
  };

  // This creates a subcollection under the specific guardian!
  await _db
      .collection('guardians')
      .doc(guardianId)
      .collection('assignedPatients')
      .doc(patientUid)
      .set(patientData);
}




// Future<void> assignPatientToGuardian({
//   required String guardianId,
//   required String patientUid,
//   required String patientEmail,
// }) async {
//   // Fetch patient name from users collection
//   final userDoc = await _db.collection('users').doc(patientUid).get();
//   String name = '';
//   if (userDoc.exists) {
//     name = userDoc.data()?['name'] ?? '';
//   }

//   final patientData = {
//     'uid': patientUid,
//     'email': patientEmail,
//     'name': name,
//     'assignedAt': FieldValue.serverTimestamp(),
//   };

//   await _db
//       .collection('guardians')
//       .doc(guardianId)
//       .collection('assignedPatients')
//       .doc(patientUid)
//       .set(patientData);
// }



Future<List<AppUser>> getAssignedPatientsForGuardian(String guardianId) async {
  final snapshot = await _db
      .collection('guardians')
      .doc(guardianId)
      .collection('assignedPatients')
      .get();

  return snapshot.docs
      .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>))
      .toList();
}

// In FirestoreService class
Future<List<AppUser>> getAllPatients() async {
  final snapshot = await _db.collection('users').where('role', isEqualTo: 'patient').get();

  return snapshot.docs
      .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>))
      .toList();
}

Future<void> assignMultiplePatientsToGuardian({
  required String guardianId,
  required List<String> patientEmails,
}) async {
  final guardianRef = _db.collection('guardians').doc(guardianId);

  // Get existing assigned patients (if any)
  final guardianDoc = await guardianRef.get();
  List existingAssigned = guardianDoc.data()?['assignedPatients'] ?? [];
  List<String> newAssignments = [];

  for (String email in patientEmails) {
    // Find patient by email in users collection
    var snapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .where('role', isEqualTo: 'patient')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String uid = snapshot.docs.first.id;

      // Prevent duplicates and max 4 assignments
      if (existingAssigned.contains(uid) ||
          newAssignments.contains(uid) ||
          (existingAssigned.length + newAssignments.length) >= 4) {
        continue;
      }

      newAssignments.add(uid);

      // Assign patient in subcollection
      await assignPatientToGuardian(
        guardianId: guardianId,
        patientUid: uid,
        patientEmail: email,
      );
    }
  }

  //Update the top-level assignedPatients array in guardian doc
  if (newAssignments.isNotEmpty) {
    await guardianRef.set({
      'assignedPatients': [...existingAssigned, ...newAssignments]
    }, SetOptions(merge: true));
  }
}

Future<AppUser?> getPatientByEmail(String email) async {
  final snapshot = await _db
      .collection('patients')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) return null;

  return AppUser.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
}

Future<Map<String, dynamic>?> getUserByUid(String uid) async {
  final doc = await _db.collection('users').doc(uid).get();
  return doc.exists ? doc.data() : null;
}

Future<void> createAppointment({
  required String patientId,
  required String doctorId,
  required DateTime apptDate,
  required String apptType,
  required String apptStatus,
  required String timeSlot,
  required String createdBy,
}) async {
  final appointmentData = {
    'patientId': patientId,
    'doctorId': doctorId,
    'apptDate': apptDate,
    'apptType': apptType,
    'apptStatus': apptStatus,
    'timeSlot': timeSlot,
    'createdBy': createdBy,
    'createdAt': FieldValue.serverTimestamp(),
  };

  // Write to top-level for doctor/global queries
  await FirebaseFirestore.instance.collection('appointments').add(appointmentData);

  // Write to patient's subcollection for patient queries
  await FirebaseFirestore.instance
      .collection('patients')
      .doc(patientId)
      .collection('appointments')
      .add(appointmentData);
}

Future<String> getDoctorNameByUid(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      print('Doctor name for $uid: ${data?['name']}');
      return data?['name'] ?? uid;
    }
    print('No doctor found for $uid');
    return uid;
  } catch (e) {
    print('Error fetching doctor name for $uid: $e');
    return uid;
  }
}

Future<String> getGuardianNameByUid(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      print('Guardian name for $uid: ${data?['name']}');
      return data?['name'] ?? uid;
    }
    print('No guardian found for $uid');
    return uid;
  } catch (e) {
    print('Error fetching guardian name for $uid: $e');
    return uid;
  }
}


}
