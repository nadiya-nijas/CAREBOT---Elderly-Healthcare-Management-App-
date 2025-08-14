import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/medical_history_model.dart';

class MedicalHistoryPage extends StatelessWidget {
  final String patientId;

  const MedicalHistoryPage({Key? key, required this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final historyRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('medicalHistory');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: historyRef.orderBy('visitDate', descending: true).limit(1).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading history'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildHistoryUI(
              MedicalHistory(
                id: '',
                bloodType: 'N/A',
                allergies: 'N/A',
                chronicDisease: 'N/A',
                visitDate: DateTime.now(),
                doctorId: '',
                notes: 'No medical history available.',
              ),
            );
          }

          final doc = snapshot.data!.docs.first;
          final history = MedicalHistory.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          return _buildHistoryUI(history);
        },
      ),
    );
  }

  Widget _buildHistoryUI(MedicalHistory history) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text("Blood Type: ${history.bloodType}", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text("Allergies: ${history.allergies}", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text("Chronic Disease: ${history.chronicDisease}", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text("Visit Date: ${history.visitDate.toLocal().toString().split(' ')[0]}", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text("Notes: ${history.notes}", style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
