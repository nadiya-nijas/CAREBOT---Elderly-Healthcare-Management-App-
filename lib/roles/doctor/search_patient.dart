import 'package:carebot/roles/doctor/patient_data.dart';
import 'package:carebot/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carebot/roles/doctor/dashboard.dart';

import 'package:carebot/roles/doctor/patient_data.dart';
import 'package:carebot/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchPatientPage extends StatefulWidget {
  @override
  State<SearchPatientPage> createState() => _SearchPatientPageState();
}

class _SearchPatientPageState extends State<SearchPatientPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();

  String? doctorId;
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  bool isLinking = false;

  @override
  void initState() {
    super.initState();
    // Get current logged-in doctor's UID
    doctorId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> searchPatients() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('email', isEqualTo: email)
          .get();

      setState(() {
        searchResults = snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _linkAndNavigate(String patientId) async {
    if (doctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doctor not logged in')),
      );
      return;
    }

    setState(() => isLinking = true);
    try {
      // Create link between doctor and patient
      await firestoreService.createDoctorPatientLink(
        doctorId: doctorId!,
        patientId: patientId,
      );

      // Fetch full patient data after linking
      final patientData = await firestoreService.fetchPatientFullDataByUid(patientId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Linked with patient successfully!')),
      );

      // Navigate to PatientData page with fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientData(patientId: patientId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to link patient: $e')),
      );
    } finally {
      setState(() => isLinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Patient')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Enter patient email',
                    ),
                    onSubmitted: (_) => searchPatients(),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: searchPatients,
                  child: Text('Search'),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator()
            else if (isLinking)
              Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Linking with patient...'),
                ],
              )
            else
              Expanded(
                child: searchResults.isEmpty
                    ? Text('No patients found.')
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final patient = searchResults[index];
                          return Card(
                            child: ListTile(
                              title: Text(patient['name'] ?? 'No Name'),
                              subtitle: Text(patient['email']),
                              onTap: () => _linkAndNavigate(patient['id']),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
