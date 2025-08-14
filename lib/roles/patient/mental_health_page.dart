import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/mental_health_model.dart';
import '../../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MentalHealthPage extends StatefulWidget {
  final String patientId;
  const MentalHealthPage({Key? key, required this.patientId}) : super(key: key);

  @override
  State<MentalHealthPage> createState() => _MentalHealthPageState();
}


class _MentalHealthPageState extends State<MentalHealthPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _auth = FirebaseAuth.instance;

  // Form fields
  int moodRating = 5;
  int stressLevel = 5;
  int sleepQuality = 5;
  int socialEngagement = 5;

  bool submittedToday = false;
  MentalHealth? submittedData;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySubmitted();
  }

  Future<void> _checkIfAlreadySubmitted() async {
    String uid = _auth.currentUser!.uid;
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot = await FirebaseFirestore.instance
        .collection('patients')
        .doc(uid)
        .collection('mentalHealth')
        .where('dateRecorded', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      setState(() {
        submittedToday = true;
        submittedData = MentalHealth.fromMap(doc.id, doc.data());
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final userId = _auth.currentUser!.uid;

    final mhEntry = MentalHealth(
      id: '', // auto-generated
      patientId: userId,
      moodRating: moodRating,
      stressLevel: stressLevel,
      sleepQuality: sleepQuality,
      socialEngagement: socialEngagement,
      dateRecorded: DateTime.now(),
      alertStatus: '',
    );

    await _firestoreService.addMentalHealth(mhEntry);

    setState(() {
      submittedToday = true;
      submittedData = mhEntry;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mental Health Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: submittedToday
            ? _buildSummaryView()
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildSlider("Mood Rating", (value) => moodRating = value),
                    _buildSlider("Stress Level", (value) => stressLevel = value),
                    _buildSlider("Sleep Quality", (value) => sleepQuality = value),
                    _buildSlider("Social Engagement", (value) => socialEngagement = value),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSlider(String label, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: (label == "Mood Rating") ? moodRating.toDouble() :
                 (label == "Stress Level") ? stressLevel.toDouble() :
                 (label == "Sleep Quality") ? sleepQuality.toDouble() :
                 socialEngagement.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: (label == "Mood Rating") ? moodRating.toString() :
                 (label == "Stress Level") ? stressLevel.toString() :
                 (label == "Sleep Quality") ? sleepQuality.toString() :
                 socialEngagement.toString(),
          onChanged: (val) {
            setState(() {
              onChanged(val.round());
            });
          },
        ),
      ],
    );
  }

  Widget _buildSummaryView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("You already submitted your entry for today.", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text("Mood Rating: ${submittedData?.moodRating ?? '-'}"),
        Text("Stress Level: ${submittedData?.stressLevel ?? '-'}"),
        Text("Sleep Quality: ${submittedData?.sleepQuality ?? '-'}"),
        Text("Social Engagement: ${submittedData?.socialEngagement ?? '-'}"),
        Text("Date: ${submittedData?.dateRecorded.toLocal().toString().split(' ')[0]}"),
      ],
    );
  }
}
