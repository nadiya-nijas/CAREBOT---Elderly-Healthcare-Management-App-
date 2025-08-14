

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carebot/services/firestore_service.dart';

class ViewAppointmentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String doctorId = FirebaseAuth.instance.currentUser!.uid;
    print('Doctor UID: $doctorId'); // For debugging

    final appointmentsRef = FirebaseFirestore.instance
        .collection('appointments')
        //.where('doctorId', isEqualTo: doctorId)
        .where('doctorId', isEqualTo: doctorId);

    return Scaffold(
      appBar: AppBar(title: Text('My Appointments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointmentsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No appointments found.'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
  final appt = docs[index].data() as Map<String, dynamic>;
  final patientId = appt['patientId'] ?? '-';
  final apptDate = appt['apptDate'] is Timestamp
      ? (appt['apptDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0]
      : appt['apptDate']?.toString() ?? '-';

  return FutureBuilder<Map<String, dynamic>?>(
    future: FirestoreService().getUserByUid(patientId),
    builder: (context, patientSnapshot) {
      String patientName = patientId;
      if (patientSnapshot.hasData && patientSnapshot.data != null) {
        patientName = patientSnapshot.data!['name'] ?? patientId;
      }
      return ListTile(
        title: Text(
          'Patient: $patientName | Date: $apptDate',
        ),
        subtitle: Text(
          'Type: ${appt['apptType'] ?? '-'} | Status: ${appt['apptStatus'] ?? '-'} | Time: ${appt['timeSlot'] ?? '-'}',
        ),
      );
    },
  );
}
          );
        },
      ),
    );
  }
}