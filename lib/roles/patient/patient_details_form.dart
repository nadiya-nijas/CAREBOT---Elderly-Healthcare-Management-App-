import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientDetailsForm extends StatefulWidget {
  final String name;
  final String email;

  const PatientDetailsForm({required this.name, required this.email, super.key});

  @override
  State<PatientDetailsForm> createState() => _PatientDetailsFormState();
}

class _PatientDetailsFormState extends State<PatientDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController userTypeController = TextEditingController(text: 'patient');

  bool isLoading = false;

  Future<void> savePatientDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('patients').doc(uid).set({
        'name': widget.name,
        'dob': dobController.text.trim(),
        'gender': genderController.text.trim(),
        'address': addressController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'user_type': userTypeController.text.trim(),
        'email': widget.email,
        'created_at': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacementNamed(context, '/patientDashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save details: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    dobController.dispose();
    genderController.dispose();
    addressController.dispose();
    phoneController.dispose();
    userTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Patient Details')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name (auto-filled, disabled)
              TextFormField(
                initialValue: widget.name,
                decoration: InputDecoration(labelText: 'Name'),
                enabled: false,
              ),

              // Email (auto-filled, disabled)
              TextFormField(
                initialValue: widget.email,
                decoration: InputDecoration(labelText: 'Email'),
                enabled: false,
              ),

              // DOB
              TextFormField(
                controller: dobController,
                decoration: InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter date of birth';
                  return null;
                },
              ),

              // Gender
              TextFormField(
                controller: genderController,
                decoration: InputDecoration(labelText: 'Gender'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter gender';
                  return null;
                },
              ),

              // Address
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter address';
                  return null;
                },
              ),

              // Phone Number
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter phone number';
                  return null;
                },
              ),

              // User Type (hidden / disabled but saved)
              TextFormField(
                controller: userTypeController,
                decoration: InputDecoration(labelText: 'User Type'),
                enabled: false,
              ),

              SizedBox(height: 30),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: savePatientDetails,
                      child: Text('Save Details'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
