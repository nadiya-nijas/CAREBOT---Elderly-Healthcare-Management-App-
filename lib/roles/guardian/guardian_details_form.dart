import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuardianDetailsForm extends StatefulWidget {
  final String name;
  final String email;

  const GuardianDetailsForm({required this.name, required this.email, super.key});

  @override
  State<GuardianDetailsForm> createState() => _GuardianDetailsFormState();
}

class _GuardianDetailsFormState extends State<GuardianDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController userTypeController = TextEditingController(text: 'guardian');

  bool isLoading = false;

  Future<void> saveGuardianDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('guardians').doc(uid).set({
        'name': widget.name,
        'phone_number': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'user_type': userTypeController.text.trim(),
        'email': widget.email,
        'created_at': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacementNamed(context, '/guardianDashboard');
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
    phoneController.dispose();
    addressController.dispose();
    userTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Guardian Details')),
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
                      onPressed: saveGuardianDetails,
                      child: Text('Save Details'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
