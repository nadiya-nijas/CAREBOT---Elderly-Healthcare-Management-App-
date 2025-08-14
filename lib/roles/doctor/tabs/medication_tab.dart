import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MedicationTab extends StatelessWidget {
  final String patientId;
  final bool editable;

  const MedicationTab({required this.patientId, this.editable = false, Key? key}) : super(key: key);

  // Show a dialog/form to add or edit medication
  Future<void> _showMedicationForm(BuildContext context, {DocumentSnapshot? doc}) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController medNameController = TextEditingController(text: doc?.get('medName') ?? '');
    final TextEditingController dosageController = TextEditingController(text: doc?.get('dosage') ?? '');
    final TextEditingController frequencyController = TextEditingController(text: doc?.get('frequency') ?? '');
    final TextEditingController startDateController = TextEditingController(text: doc?.get('startDate') ?? '');
    final TextEditingController endDateController = TextEditingController(text: doc?.get('endDate') ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? 'Add Medication' : 'Edit Medication'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: medNameController,
                  decoration: InputDecoration(labelText: 'Medication Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: dosageController,
                  decoration: InputDecoration(labelText: 'Dosage'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: frequencyController,
                  decoration: InputDecoration(labelText: 'Frequency (e.g., Morning, Evening)'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: startDateController,
                  decoration: InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: endDateController,
                  decoration: InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final collection = FirebaseFirestore.instance
                    .collection('patients')
                    .doc(patientId)
                    .collection('medications');

                if (doc == null) {
                  // Add new medication
                  await collection.add({
                    'medName': medNameController.text.trim(),
                    'dosage': dosageController.text.trim(),
                    'frequency': frequencyController.text.trim(),
                    'startDate': startDateController.text.trim(),
                    'endDate': endDateController.text.trim(),
                    'med_status': 'Current',
                  });
                } else {
                  // Update existing medication
                  await collection.doc(doc.id).update({
                    'medName': medNameController.text.trim(),
                    'dosage': dosageController.text.trim(),
                    'frequency': frequencyController.text.trim(),
                    'startDate': startDateController.text.trim(),
                    'endDate': endDateController.text.trim(),
                  });
                }
                Navigator.pop(context);
              }
            },
            child: Text(doc == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  // Confirm deletion dialog
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Medication?'),
            content: Text('Are you sure you want to delete this medication?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final medicationsRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('medications');

    return StreamBuilder<QuerySnapshot>(
      stream: medicationsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final meds = snapshot.data!.docs;

        if (meds.isEmpty) {
          return Center(child: Text('No medications found'));
        }

        return ListView.builder(
          itemCount: meds.length,
          itemBuilder: (context, index) {
            final doc = meds[index];
            final data = doc.data()! as Map<String, dynamic>;

            return ListTile(
              title: Text(data['medName'] ?? 'Unknown'),
              subtitle: Text(
                  'Dosage: ${data['dosage'] ?? '-'}\nFrequency: ${data['frequency'] ?? '-'}\nStart: ${data['startDate'] ?? '-'}\nEnd: ${data['endDate'] ?? '-'}\nStatus: ${data['med_status'] ?? '-'}'),
              isThreeLine: true,
              trailing: editable
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showMedicationForm(context, doc: doc),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await _confirmDelete(context);
                            if (confirmed) {
                              await medicationsRef.doc(doc.id).delete();
                            }
                          },
                        ),
                      ],
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}

// class MedicationTab extends StatelessWidget {
//   final String patientId;
//   const MedicationTab({required this.patientId, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('medication')
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
//               title: Text(data['Med_Name'] ?? 'No Name'),
//               subtitle: Text("Dosage: ${data['Dosage']} | Status: ${data['Med_status']}"),
//             );
//           },
//         );
//       },
//     );
//   }
// }
