
import 'package:carebot/roles/patient/medications_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import your real pages with patientId parameter
import 'package:carebot/roles/patient/medical_history_page.dart';
import 'package:carebot/roles/patient/health_metrics_page.dart';
import 'package:carebot/roles/patient/mental_health_page.dart';

import 'package:carebot/roles/patient/appointments_page.dart';  // If you have this page

class PatientDashboard extends StatelessWidget {
  final String patientId = FirebaseAuth.instance.currentUser!.uid;

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        'title': 'Medical History',
        'icon': Icons.history,
        'page': MedicalHistoryPage(patientId: patientId),
      },
      {
        'title': 'Health Metrics',
        'icon': Icons.monitor_heart,
        'page': HealthMetricsPage(patientId: patientId),
      },
      {
        'title': 'Appointments',
        'icon': Icons.calendar_today,
        'page': AppointmentPage(patientId: patientId),  // pass patientId if required
      },
      {
        'title': 'Mental Health',
        'icon': Icons.psychology,
        'page': MentalHealthPage(patientId: patientId),
      },
      {
        'title': 'Medication',
        'icon': Icons.medication,
        'page': MedicationViewPage(patientId: patientId),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: features.map((feature) {
            return InkWell(
              onTap: () => navigateTo(context, feature['page']),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(feature['icon'], size: 40, color: Colors.blue),
                      const SizedBox(height: 10),
                      Text(
                        feature['title'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// //🔒 Unchanged sections
// class AppointmentsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) =>
//       Scaffold(appBar: AppBar(title: Text("Appointments")));
// }

// class MentalHealthPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) =>
//       Scaffold(appBar: AppBar(title: Text("Mental Health")));
// }

// class MedicationPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) =>
//       Scaffold(appBar: AppBar(title: Text("Medication")));
// }
