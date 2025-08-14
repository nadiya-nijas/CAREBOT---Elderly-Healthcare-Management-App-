import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> redirectPatientAfterLogin(BuildContext context) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) return; // safety check

  final doc = await FirebaseFirestore.instance.collection('patients').doc(uid).get();

  if (doc.exists) {
    Navigator.pushReplacementNamed(context, '/patientDashboard');
  } else {
    Navigator.pushReplacementNamed(context, '/patientDetailsForm');
  }
}

