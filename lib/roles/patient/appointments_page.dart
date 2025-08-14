

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/appointment_model.dart';
import 'package:carebot/services/firestore_service.dart';

Future<String> getUserNameByUid(String uid) async {
  final data = await FirestoreService().getUserByUid(uid);
  return data?['name'] ?? uid;
}
class AppointmentPage extends StatelessWidget {
  final String patientId;

  const AppointmentPage({Key? key, required this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appointmentsRef = FirebaseFirestore.instance
  .collection('patients')
  .doc(patientId)
  .collection('appointments')
  .orderBy('apptDate', descending: false);

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointmentsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No appointments found.'));
          }

          final appointments = docs
              .map((doc) => Appointment.fromMap(doc.id, doc.data()! as Map<String, dynamic>))
              .toList();

          return ListView.builder(
  itemCount: appointments.length,
  itemBuilder: (context, index) {
    final appt = appointments[index];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: FutureBuilder<List<Map<String, dynamic>?>>(
        future: Future.wait([
          FirestoreService().getUserByUid(appt.doctorId),
          FirestoreService().getUserByUid(appt.createdBy),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ListTile(
              title: Text('Loading...'),
              subtitle: Text('Fetching doctor and guardian names...'),
            );
          }
          if (snapshot.hasError) {
            return ListTile(
              title: Text('${appt.apptType} (${appt.apptStatus})'),
              subtitle: Text('Error loading names'),
            );
          }
          final doctorData = snapshot.data?[0];
          final guardianData = snapshot.data?[1];
          final doctorName = doctorData?['name'] ?? appt.doctorId;
          final guardianName = guardianData?['name'] ?? appt.createdBy;
          return ListTile(
            title: Text('${appt.apptType} (${appt.apptStatus})'),
            subtitle: Text(
              'Date: ${appt.apptDate.toLocal().toString().split(' ')[0]}\n'
              'Time: ${appt.timeSlot}\n'
              'Doctor: $doctorName\n'
              'Guardian: $guardianName',
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  },
);
        },
      ),
    );
  }
}
