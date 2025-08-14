import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateMedicalHistoryPage extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> history;

  const UpdateMedicalHistoryPage({
    Key? key,
    required this.patientId,
    required this.history, required Map<String, dynamic> historyData,
  }) : super(key: key);

  @override
  State<UpdateMedicalHistoryPage> createState() => _UpdateMedicalHistoryPageState();
}

class _UpdateMedicalHistoryPageState extends State<UpdateMedicalHistoryPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController bloodTypeController;
  late TextEditingController allergiesController;
  late TextEditingController chronicDiseaseController;
  late TextEditingController notesController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    bloodTypeController = TextEditingController(text: widget.history['bloodType'] ?? '');
    allergiesController = TextEditingController(text: widget.history['allergies'] ?? '');
    chronicDiseaseController = TextEditingController(text: widget.history['chronicDisease'] ?? '');
    notesController = TextEditingController(text: widget.history['notes'] ?? '');
  }

  @override
  void dispose() {
    bloodTypeController.dispose();
    allergiesController.dispose();
    chronicDiseaseController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _saveUpdates() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final historyRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .collection('medicalHistory');

    Map<String, dynamic> updatedData = {
      'bloodType': bloodTypeController.text.trim(),
      'allergies': allergiesController.text.trim(),
      'chronicDisease': chronicDiseaseController.text.trim(),
      'notes': notesController.text.trim(),
      'visitDate': DateTime.now(),
      'doctorId': widget.history['doctorId'] ?? '',
    };

    try {
      final docId = widget.history['id'] ?? '';

      if (docId.isEmpty) {
        await historyRef.add(updatedData);
      } else {
        await historyRef.doc(docId).update(updatedData);
      }

      Navigator.pop(context, true); // return true to indicate success
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update medical history: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Medical History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: bloodTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Blood Type',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Please enter blood type' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: allergiesController,
                      decoration: const InputDecoration(
                        labelText: 'Allergies',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: chronicDiseaseController,
                      decoration: const InputDecoration(
                        labelText: 'Chronic Disease',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveUpdates,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
