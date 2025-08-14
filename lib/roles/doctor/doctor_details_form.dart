import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDetailsForm extends StatefulWidget {
  final String name;
  final String email;

  const DoctorDetailsForm({required this.name, required this.email, super.key});

  @override
  State<DoctorDetailsForm> createState() => _DoctorDetailsFormState();
}

class _DoctorDetailsFormState extends State<DoctorDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController userTypeController = TextEditingController(text: 'doctor');

  bool isLoading = false;

  Future<void> saveDoctorDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('doctors').doc(uid).set({
        'name': widget.name,
        'specialization': specializationController.text.trim(),
        'license_number': licenseNumberController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'user_type': userTypeController.text.trim(),
        'email': widget.email,
        'created_at': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacementNamed(context, '/dashboard');
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
    specializationController.dispose();
    licenseNumberController.dispose();
    phoneController.dispose();
    addressController.dispose();
    userTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Doctor Details')),
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

              // Specialization
              TextFormField(
                controller: specializationController,
                decoration: InputDecoration(labelText: 'Specialization'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter specialization';
                  return null;
                },
              ),

              // License Number
              TextFormField(
                controller: licenseNumberController,
                decoration: InputDecoration(labelText: 'License Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter license number';
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

              // Address
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter address';
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
                      onPressed: saveDoctorDetails,
                      child: Text('Save Details'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
