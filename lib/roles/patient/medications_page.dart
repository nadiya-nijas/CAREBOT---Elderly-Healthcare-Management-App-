import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carebot/models/medication_model.dart';


class MedicationViewPage extends StatelessWidget {
  final String patientId;
  const MedicationViewPage({super.key, required this.patientId});


  Future<List<Medication>> fetchMedications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('medications')
        .get();


    return snapshot.docs
        .map((doc) => Medication.fromMap(doc.id, doc.data()))
        .toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Medications')),
      body: FutureBuilder<List<Medication>>(
        future: fetchMedications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No medications found.'));
          }


          final medications = snapshot.data!;
          return ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final med = medications[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(med.medName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dosage: ${med.dosage}'),
                      Text('Status: ${med.medStatus}'),
                      Text('Start: ${med.startDate.toLocal()}'),
                      Text('End: ${med.endDate.toLocal()}'),
                      Text('Frequency: ${med.frequency.join(', ')}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


