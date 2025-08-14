import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:carebot/roles/doctor/doctor_details_form.dart';
import 'package:carebot/roles/guardian/guardian_details_form.dart';
import 'package:carebot/roles/patient/patient_details_form.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'patient'; // default role
  bool isLoading = false;

  void signUp() async {
    setState(() {
      isLoading = true;
    });

    try {
      await AuthService().signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
        nameController.text.trim(),
        selectedRole,
      );

      // Navigate to role-based form
      Widget nextScreen;
      switch (selectedRole) {
        case 'doctor':
          nextScreen = DoctorDetailsForm(name: nameController.text.trim(), email: emailController.text.trim());
          break;
        case 'guardian':
          nextScreen = GuardianDetailsForm(name: nameController.text.trim(), email: emailController.text.trim());
          break;
        default:
          nextScreen = PatientDetailsForm(name: nameController.text.trim(), email: emailController.text.trim());
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } catch (e) {
      print("Signup failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Full Name"),
              ),
              SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(labelText: "Select Role"),
                items: [
                  DropdownMenuItem(value: 'patient', child: Text('Patient')),
                  DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                  DropdownMenuItem(value: 'guardian', child: Text('Guardian')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value ?? 'patient';
                  });
                },
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: signUp,
                      child: Text("Sign Up"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}