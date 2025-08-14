import 'package:flutter/material.dart';
import 'package:carebot/roles/guardian/assign_patient.dart'; // or wherever it's located

import 'patient_tracker.dart';

class GuardianDashboard extends StatelessWidget {
  final String guardianId;

  const GuardianDashboard({Key? key, required this.guardianId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardian Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, Guardian!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.assignment),
              label: Text('Assign Patients'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssignPatientPage(guardianId: guardianId),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.group),
              label: Text('View My Patients'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GuardianPatientTrackerPage(guardianId: guardianId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
