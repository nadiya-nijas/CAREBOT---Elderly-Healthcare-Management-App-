import 'package:carebot/roles/guardian/guardian_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'signup_page.dart';
import '../services/auth_service.dart';
import '../roles/patient/patient_details_form.dart';
import '../roles/doctor/doctor_details_form.dart';
import '../roles/guardian/guardian_details_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void login() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Authenticate the user
      await AuthService().login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Get user details
      AppUser user = await FirestoreService().getUser(uid);
      print('User fetched: ${user.name}, role: ${user.role}, email: ${user.email}');

      // Navigate based on role
      if (user.role == 'doctor') {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('doctors')
              .doc(uid)
              .get();

          if (doc.exists) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DoctorDetailsForm(name: user.name, email: user.email),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error accessing doctor data: $e')),
          );
        }
      } else if (user.role == 'patient') {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('patients')
              .doc(uid)
              .get();

          if (doc.exists) {
            Navigator.pushReplacementNamed(context, '/patientDashboard');
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PatientDetailsForm(name: user.name, email: user.email),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error accessing patient data: $e')),
          );
        }
      } else if (user.role == 'guardian') {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('guardians')
              .doc(uid)
              .get();

          if (doc.exists) {
            Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => GuardianDashboard(guardianId: uid),
  ),
);
            // Navigator.pushReplacementNamed(context, '/guardianDashboard');
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => GuardianDetailsForm(name: user.name, email: user.email),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error accessing guardian data: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unknown role: ${user.role}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
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
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: Text("Login"),
                  ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupPage()),
                );
              },
              child: Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
