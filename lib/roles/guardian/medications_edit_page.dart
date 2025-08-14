import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/medication_model.dart';

class MedicationPage extends StatefulWidget {
  final String patientId;

  const MedicationPage({Key? key, required this.patientId}) : super(key: key);

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final TextEditingController _medNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();

  List<String> selectedFrequency = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String medStatus = 'Current';
  String? _editingDocId;

  final List<String> frequencyOptions = ['Morning', 'Afternoon', 'Evening'];

  @override
  void initState() {
    super.initState();
    _loadTodayMedication();
  }

  Future<void> _loadTodayMedication() async {
    final today = DateTime.now();
    final collection = FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .collection('medications');

    final snapshot = await collection
        .where('startDate', isGreaterThanOrEqualTo: DateTime(today.year, today.month, today.day))
        .where('startDate', isLessThan: DateTime(today.year, today.month, today.day + 1))
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final med = Medication.fromMap(doc.id, doc.data());

      setState(() {
        _editingDocId = doc.id;
        _medNameController.text = med.medName;
        _dosageController.text = med.dosage;
        selectedFrequency = List<String>.from(med.frequency);
        startDate = med.startDate;
        endDate = med.endDate;
        medStatus = med.medStatus;
      });
    }
  }

  Future<void> _submitMedication() async {
    final collection = FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .collection('medications');

    final medData = {
      'Med_Name': _medNameController.text.trim(),
      'Dosage': _dosageController.text.trim(),
      'Frequency': selectedFrequency,
      'StartDate': startDate,
      'EndDate': endDate,
      'Med_status': medStatus,
      'Doctor_ID': '', // Optional if not available
      'Patient_ID': widget.patientId,
    };

    if (_editingDocId != null) {
      await collection.doc(_editingDocId).update(medData);
    } else {
      await collection.add(medData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_editingDocId != null ? 'Medication updated' : 'Medication added')),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Widget _buildFrequencyChips() {
    return Wrap(
      spacing: 10,
      children: frequencyOptions.map((freq) {
        final isSelected = selectedFrequency.contains(freq);
        return FilterChip(
          label: Text(freq),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              if (val) {
                selectedFrequency.add(freq);
              } else {
                selectedFrequency.remove(freq);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medsRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .collection('medications');

    return Scaffold(
      appBar: AppBar(title: const Text('Medications')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Medication Name"),
            TextField(controller: _medNameController),

            const SizedBox(height: 10),
            const Text("Dosage"),
            TextField(controller: _dosageController),

            const SizedBox(height: 10),
            const Text("Frequency"),
            _buildFrequencyChips(),

            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Start Date: "),
                TextButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text("${startDate.toLocal()}".split(' ')[0]),
                ),
              ],
            ),
            Row(
              children: [
                const Text("End Date: "),
                TextButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text("${endDate.toLocal()}".split(' ')[0]),
                ),
              ],
            ),

            const SizedBox(height: 10),
            DropdownButton<String>(
              value: medStatus,
              items: ['Current', 'Past'].map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => medStatus = val);
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitMedication,
              child: Text(_editingDocId != null ? "Update Medication" : "Add Medication"),
            ),

            const Divider(height: 40),

            const Text("All Medications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: medsRef.orderBy('startDate', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Text('No medications found.');

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final med = Medication.fromMap(docs[index].id, docs[index].data() as Map<String, dynamic>);
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Medication: ${med.medName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("Dosage: ${med.dosage}"),
                            Text("Frequency: ${med.frequency.join(', ')}"),
                            Text("Start: ${med.startDate.toLocal().toString().split(' ')[0]}"),
                            Text("End: ${med.endDate.toLocal().toString().split(' ')[0]}"),
                            Text("Status: ${med.medStatus}"),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
