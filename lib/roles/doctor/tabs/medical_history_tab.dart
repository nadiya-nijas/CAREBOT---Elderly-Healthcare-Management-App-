import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class MedicalHistoryTab extends StatelessWidget {
  final String patientId;
  final bool editable;

  const MedicalHistoryTab({required this.patientId, this.editable = false, Key? key}) : super(key: key);

  Future<void> _editMedicalHistory(BuildContext context, String historyId, Map<String, dynamic> data) async {
    // Open form to edit and save changes
  }

  @override
  Widget build(BuildContext context) {
    final collection = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('medicalHistory');

    return StreamBuilder<QuerySnapshot>(
      stream: collection.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final id = docs[i].id;

            return ListTile(
              title: Text(data['description'] ?? 'No description'),
              subtitle: Text(data['date'] ?? ''),
              trailing: editable
                  ? IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editMedicalHistory(context, id, data),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}


// class MedicalHistoryTab extends StatelessWidget {
//   final String patientId;
//   const MedicalHistoryTab({required this.patientId, super.key});

//   Future<void> _createDefaultMedicalHistoryIfNone() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('medical_history')
//         .where('patientId', isEqualTo: patientId)
//         .limit(1)
//         .get();

//     if (snapshot.docs.isEmpty) {
//       await _addMedicalRecord(); // call below function
//     }
//   }

//   Future<void> _addMedicalRecord({String? diagnosis, String? notes}) async {
//     final doctorId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
//     await FirebaseFirestore.instance.collection('medical_history').add({
//       'patientId': patientId,
//       'doctorId': doctorId,
//       'diagnosis': diagnosis ?? 'Sample Diagnosis',
//       'medications': ['Sample Medication'],
//       'notes': notes ?? 'Manually added record.',
//       'visitDate': DateTime.now().toIso8601String(),
//     });
//   }

//   void _showAddDialog(BuildContext context) {
//     final diagnosisController = TextEditingController();
//     final notesController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Add Medical Record"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: diagnosisController,
//               decoration: const InputDecoration(labelText: 'Diagnosis'),
//             ),
//             TextField(
//               controller: notesController,
//               decoration: const InputDecoration(labelText: 'Notes'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           ElevatedButton(
//             onPressed: () async {
//               await _addMedicalRecord(
//                 diagnosis: diagnosisController.text.trim(),
//                 notes: notesController.text.trim(),
//               );
//               Navigator.pop(context);
//             },
//             child: const Text("Add"),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _createDefaultMedicalHistoryIfNone(),
//       builder: (context, _) {
//         return Column(
//           children: [
//             ElevatedButton.icon(
//               onPressed: () => _showAddDialog(context),
//               icon: const Icon(Icons.add),
//               label: const Text("Add Medical Record"),
//             ),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('medical_history')
//                     .where('patientId', isEqualTo: patientId)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//                   final docs = snapshot.data!.docs;
//                   return ListView.builder(
//                     itemCount: docs.length,
//                     itemBuilder: (context, index) {
//                       final data = docs[index].data() as Map<String, dynamic>;
//                       return ListTile(
//                         title: Text(data['diagnosis'] ?? 'No Diagnosis'),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Date: ${data['visitDate'] ?? ''}"),
//                             if (data['medications'] != null)
//                               Text("Medications: ${(data['medications'] as List).join(', ')}"),
//                             if (data['notes'] != null)
//                               Text("Notes: ${data['notes']}"),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }


//old2
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class MedicalHistoryTab extends StatefulWidget {
//   final String patientId;
//   const MedicalHistoryTab({required this.patientId, super.key});

//   @override
//   State<MedicalHistoryTab> createState() => _MedicalHistoryTabState();
// }

// class _MedicalHistoryTabState extends State<MedicalHistoryTab> {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   bool _checked = false;

//   @override
//   void initState() {
//     super.initState();
//     _ensureMedicalHistoryExists();
//   }

//   Future<void> _ensureMedicalHistoryExists() async {
//     final query = await _db
//         .collection('medical_history')
//         .where('patientId', isEqualTo: widget.patientId)
//         .limit(1)
//         .get();

//     if (query.docs.isEmpty) {
//       await _db.collection('medical_history').add({
//         'patientId': widget.patientId,
//         'doctorId': 'unknown', // or pass doctorId if you have it here
//         'diagnosis': 'Not yet diagnosed',
//         'visitDate': DateTime.now().toIso8601String(),
//         'notes': 'Auto-created on first view',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     }

//     setState(() {
//       _checked = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_checked) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     return StreamBuilder<QuerySnapshot>(
//       stream: _db
//           .collection('medical_history')
//           .where('patientId', isEqualTo: widget.patientId)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//         final docs = snapshot.data!.docs;
//         return ListView.builder(
//           itemCount: docs.length,
//           itemBuilder: (context, index) {
//             final data = docs[index].data() as Map<String, dynamic>;
//             return ListTile(
//               title: Text(data['diagnosis'] ?? 'No Diagnosis'),
//               subtitle: Text(data['visitDate'] ?? ''),
//             );
//           },
//         );
//       },
//     );
//   }
// }


//-old1
// class MedicalHistoryTab extends StatelessWidget {
//   final String patientId;
//   const MedicalHistoryTab({required this.patientId, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('medical_history')
//           .where('patientId', isEqualTo: patientId)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//         final docs = snapshot.data!.docs;
//         return ListView.builder(
//           itemCount: docs.length,
//           itemBuilder: (context, index) {
//             final data = docs[index].data() as Map<String, dynamic>;
//             return ListTile(
//               title: Text(data['diagnosis'] ?? 'No Diagnosis'),
//               subtitle: Text(data['visitDate'] ?? ''),
//             );
//           },
//         );
//       },
//     );
//   }
// }
