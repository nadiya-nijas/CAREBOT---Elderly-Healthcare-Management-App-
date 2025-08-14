import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHealthMetricDialog extends StatefulWidget {
  final String patientId;

  const AddHealthMetricDialog({Key? key, required this.patientId}) : super(key: key);

  @override
  State<AddHealthMetricDialog> createState() => _AddHealthMetricDialogState();
}

class _AddHealthMetricDialogState extends State<AddHealthMetricDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController bpController = TextEditingController();
  final TextEditingController hrController = TextEditingController();
  final TextEditingController o2Controller = TextEditingController();
  final TextEditingController sugarController = TextEditingController();

  bool isSaving = false;

  Future<void> saveHealthMetric() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('healthMetrics')
          .add({
        'height': double.tryParse(heightController.text) ?? 0.0,
        'weight': double.tryParse(weightController.text) ?? 0.0,
        'temperature': double.tryParse(tempController.text) ?? 0.0,
        'bloodPressure': bpController.text,
        'heartRate': int.tryParse(hrController.text) ?? 0,
        'o2Saturation': double.tryParse(o2Controller.text) ?? 0.0,
        'bloodSugarLevel': double.tryParse(sugarController.text) ?? 0.0,
        'dateRecorded': Timestamp.now(),
      });

      Navigator.of(context).pop(); // Close dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving health metric: $e')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    tempController.dispose();
    bpController.dispose();
    hrController.dispose();
    o2Controller.dispose();
    sugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Health Metric'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField('Height (cm)', heightController),
              _buildField('Weight (kg)', weightController),
              _buildField('Temperature (°C)', tempController),
              _buildField('Blood Pressure', bpController),
              _buildField('Heart Rate (bpm)', hrController),
              _buildField('O2 Saturation (%)', o2Controller),
              _buildField('Blood Sugar Level (mg/dL)', sugarController),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : saveHealthMetric,
          child: isSaving ? CircularProgressIndicator(color: Colors.white) : Text('Save'),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }
}
