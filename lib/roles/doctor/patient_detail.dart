import 'package:flutter/material.dart';
import 'tabs/medication_tab.dart';
import 'tabs/medical_history_tab.dart';

class PatientDetail extends StatelessWidget {
  final String patientId;
  const PatientDetail({required this.patientId, super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Patient Details'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Medical History'),
              Tab(text: 'Medication'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MedicalHistoryTab(patientId: patientId),
            MedicationTab(patientId: patientId),
          ],
        ),
      ),
    );
  }
}
