import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_patient.dart';
import 'view_appointments.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchDoctorData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No logged-in user');
    }

    return FirebaseFirestore.instance
        .collection('doctors')
        .doc(currentUser.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _fetchDoctorData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Doctor profile not found.'));
          }

          final doctorData = snapshot.data!.data()!;
          final name = doctorData['name'] ?? 'Doctor';
          final specialization = doctorData['specialization'] ?? 'Specialization';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section with colored background
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 222, 125, 157),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        specialization,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24), // Space after top section

                ElevatedButton.icon(
                  icon: Icon(Icons.search),
                  label: Text('Search Patient'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SearchPatientPage()),
                    );
                  },
                ),

                // Add more dashboard options here
                ElevatedButton.icon(
  icon: Icon(Icons.calendar_today),
  label: Text('View My Appointments'),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewAppointmentsPage()),
    );
  },
),
              ],
            ),
          );
        },
      ),
    );
  }
}




// class DoctorDashboard extends StatefulWidget {
//   const DoctorDashboard({super.key});

//   @override
//   State<DoctorDashboard> createState() => _DoctorDashboardState();
// }

// class _DoctorDashboardState extends State<DoctorDashboard> {
//   final TextEditingController _emailController = TextEditingController();
//   final String currentDoctorId = FirebaseAuth.instance.currentUser!.uid;

//   Future<void> linkPatientByEmail(String email) async {
//     try {
//       await FirestoreService().linkPatient(currentDoctorId, email);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Patient linked successfully!")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     }
//   }

//   Future<void> unlinkPatient(String patientId) async {
//     await FirestoreService().unlinkPatient(currentDoctorId, patientId);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Patient unlinked successfully.")),
//     );
//   }

//   Stream<List<Map<String, dynamic>>> getLinkedPatients() {
//     return FirestoreService().getPatientsForDoctor(currentDoctorId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Doctor Dashboard')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _emailController,
//                     decoration: const InputDecoration(labelText: "Enter patient's email"),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => linkPatientByEmail(_emailController.text.trim()),
//                   child: const Text('Add Patient'),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<List<Map<String, dynamic>>>(
//               stream: getLinkedPatients(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//                 final patients = snapshot.data!;
//                 return ListView.builder(
//                   itemCount: patients.length,
//                   itemBuilder: (context, index) {
//                     final patient = patients[index];
//                     return ListTile(
//                       title: Text(patient['name'] ?? 'No Name'),
//                       subtitle: Text(patient['email'] ?? ''),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
//                         onPressed: () => unlinkPatient(patient['id']),
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => PatientDetail(patientId: patient['id']),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class DoctorDashboard extends StatelessWidget {
//   final String doctorId = FirebaseAuth.instance.currentUser!.uid;

//   void navigateToPatientDetails(BuildContext context, String patientId) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PatientDetailsPage(patientId: patientId),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Stream patients where doctorIds array contains current doctorId
//     return Scaffold(
//       appBar: AppBar(title: Text('Doctor Dashboard')),
//       body: Column(
//         children: [
//           // TODO: Add doctor details widget here
//           Container(
//             padding: EdgeInsets.all(16),
//             child: Text(
//               'Welcome, Doctor!',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//           ),

//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('patients')
//                   .where('doctorIds', arrayContains: doctorId)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(child: Text('No patients found.'));
//                 }

//                 final patients = snapshot.data!.docs;

//                 return GridView.builder(
//                   padding: EdgeInsets.all(12),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     mainAxisSpacing: 12,
//                     crossAxisSpacing: 12,
//                     childAspectRatio: 3 / 2,
//                   ),
//                   itemCount: patients.length,
//                   itemBuilder: (context, index) {
//                     final patient = patients[index];
//                     final patientName = patient['name'] ?? 'Unnamed';
//                     final patientId = patient.id;

//                     return InkWell(
//                       onTap: () => navigateToPatientDetails(context, patientId),
//                       child: Card(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 4,
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               patientName,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Placeholder patient details page
// class PatientDetailsPage extends StatelessWidget {
//   final String patientId;

//   const PatientDetailsPage({required this.patientId, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Patient Details')),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance.collection('patients').doc(patientId).get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting)
//             return Center(child: CircularProgressIndicator());

//           if (!snapshot.hasData || !snapshot.data!.exists)
//             return Center(child: Text('Patient data not found.'));

//           final patientData = snapshot.data!.data() as Map<String, dynamic>;

//           return Padding(
//             padding: const EdgeInsets.all(16),
//             child: ListView(
//               children: [
//                 Text('Name: ${patientData['name'] ?? ''}', style: TextStyle(fontSize: 18)),
//                 SizedBox(height: 8),
//                 Text('DOB: ${patientData['dob'] ?? ''}'),
//                 SizedBox(height: 8),
//                 Text('Gender: ${patientData['gender'] ?? ''}'),
//                 SizedBox(height: 8),
//                 Text('Address: ${patientData['address'] ?? ''}'),
//                 SizedBox(height: 8),
//                 Text('Phone: ${patientData['phone_number'] ?? ''}'),
//                 // Add more patient fields as needed
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
