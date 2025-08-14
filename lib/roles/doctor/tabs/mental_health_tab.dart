// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class MentalHealthTab extends StatelessWidget {
//   final String patientId;

//   const MentalHealthTab({required this.patientId});

//   @override
//   Widget build(BuildContext context) {
//     final ref = FirebaseFirestore.instance
//         .collection('mental_health')
//         .where('patient_id', isEqualTo: patientId)
//         .orderBy('date', descending: true);
//         return StreamBuilder<QuerySnapshot>(
//   stream: ref.snapshots(),
//   builder: (context, snapshot) {
//     if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
//     final docs = snapshot.data!.docs;

//     if (docs.isEmpty) return Center(child: Text("No mental health records"));

//     return ListView.builder(
//       itemCount: docs.length,
//       itemBuilder: (context, index) {
//         final d = docs[index].data() as Map<String, dynamic>;
//         return ListTile(
//           title: Text(d['status'] ?? 'No status'),
//           subtitle: Text(d['notes'] ?? ''),
//           trailing: Text(d['date'] != null
//               ? (d['date'] as Timestamp).toDate().toString().split(' ')[0]
//               : ''),
//         );
//       },
//     );
//   },
// );
//   }
// }

