
import 'package:flutter/material.dart';
import 'package:carebot/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../guardian/medications_edit_page.dart';
import 'update_medical_history.dart'; // Make sure this import path is correct

class PatientData extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic>? patientData; // optional pre-fetched data

  const PatientData({
    Key? key,
    required this.patientId,
    this.patientData,
  }) : super(key: key);

  @override
  State<PatientData> createState() => _PatientDataState();
}

class _PatientDataState extends State<PatientData> {
  final FirestoreService firestoreService = FirestoreService();

  Map<String, dynamic>? _patientData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.patientData != null) {
      // Use passed data directly
      _patientData = widget.patientData;
      isLoading = false;
    } else {
      fetchPatientData();
    }
  }

  Future<void> fetchPatientData() async {
    try {
      final docSnapshot = await firestoreService.getPatientDocument(widget.patientId);

      final medicalHistory = await firestoreService.getMedicalHistoryOnce(widget.patientId);
      final medications = await firestoreService.getMedicationsOnce(widget.patientId);
      final healthMetrics = await firestoreService.getHealthMetricsOnce(widget.patientId);

      setState(() {
        _patientData = {
          'patientDoc': docSnapshot.data(),
          'medicalHistory': medicalHistory,
          'medications': medications,
          'healthMetrics': healthMetrics,
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshMedicalHistory() async {
    final medicalHistory = await firestoreService.getMedicalHistoryOnce(widget.patientId);
    setState(() {
      _patientData?['medicalHistory'] = medicalHistory;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Patient Details')),
        body: Center(child: Text('Error: $error')),
      );
    }

    final patientInfo = _patientData?['patientDoc'] ?? {};
    final medicalHistory = _patientData?['medicalHistory'] ?? [];
    final medications = _patientData?['medications'] ?? [];
    final healthMetrics = _patientData?['healthMetrics'] ?? [];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(patientInfo['name'] ?? 'Patient Details'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Medical History'),
              Tab(text: 'Medications'),
              Tab(text: 'Health Metrics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMedicalHistoryTab(medicalHistory),
            _buildMedicationsTab(),
            _buildHealthMetricsTab(healthMetrics),
          ],
        ),

      ),
    );
  }


  Widget _buildMedicalHistoryTab(List<dynamic> medicalHistory) {
  return Stack(
    children: [
      medicalHistory.isEmpty
          ? const Center(child: Text('No medical history found.'))
          : ListView.builder(
              itemCount: medicalHistory.length,
              itemBuilder: (context, index) {
                final item = medicalHistory[index];

                String visitDateStr = '';
                if (item['visitDate'] != null) {
                  if (item['visitDate'] is Timestamp) {
                    visitDateStr = (item['visitDate'] as Timestamp)
                        .toDate()
                        .toLocal()
                        .toString()
                        .split(' ')[0];
                  } else {
                    visitDateStr = item['visitDate'].toString();
                  }
                }

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Allergies: ${item['allergies'] ?? '-'}'),
                        const SizedBox(height: 4),
                        Text('Blood Type: ${item['bloodType'] ?? '-'}'),
                        const SizedBox(height: 4),
                        Text('Chronic Disease: ${item['chronicDisease'] ?? '-'}'),
                        const SizedBox(height: 4),
                        Text('Doctor ID: ${item['doctorId'] ?? '-'}'),
                        const SizedBox(height: 4),
                        Text('Notes: ${item['notes'] ?? '-'}'),
                        const SizedBox(height: 4),
                        Text('Visit Date: $visitDateStr'),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              // Pass full MedicalHistory-like map including document ID
                              bool? updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UpdateMedicalHistoryPage(
                                    patientId: widget.patientId,
                                    historyData: {
                                      'id': item['id'] ?? '',
                                      'bloodType': item['bloodType'],
                                      'allergies': item['allergies'],
                                      'chronicDisease': item['chronicDisease'],
                                      'notes': item['notes'],
                                      'visitDate': item['visitDate'],
                                      'doctorId': item['doctorId'],
                                      'medications': item['medications'],
                                    },
                                    history: {},
                                  ),
                                ),
                              );

                              if (updated == true) {
                                await _refreshMedicalHistory();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      // Add button for adding new medical history (bottom right)
      Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton(
          heroTag: 'add_medical_history',
          onPressed: () async {
            bool? added = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UpdateMedicalHistoryPage(
                  patientId: widget.patientId,
                  historyData: {}, // empty map for new record
                  history: {},
                ),
              ),
            );
            if (added == true) {
              await _refreshMedicalHistory();
            }
          },
          child: const Icon(Icons.add),
          tooltip: 'Add Medical History',
        ),
      ),
    ],
  );
  }


Widget _buildMedicationsTab() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .collection('medications')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Stack(
          children: [
            const Center(child: Text('No medications found.')),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'add_medication',
                onPressed: () async {
                  bool? added = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicationPage(
                        patientId: widget.patientId,
                      ),
                    ),
                  );
                  // No need to manually refresh — StreamBuilder handles it
                },
                child: const Icon(Icons.add),
                tooltip: 'Add Medication',
              ),
            ),
          ],
        );
      }

      final medications = snapshot.data!.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include doc ID
        return data;
      }).toList();

      return Stack(
        children: [
          ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final med = medications[index];
              final medId = med['id'] ?? '';
              final medName = med['Med_Name'] ?? med['med_name'] ?? 'Medication';
              final dosage = med['Dosage'] ?? med['dosage'] ?? 'N/A';
              final frequency = (med['Frequency'] ?? med['frequency'] ?? []).join(', ');
              final startDate = med['StartDate'] ?? med['startDate'];
              final endDate = med['EndDate'] ?? med['endDate'];
              final medStatus = med['Med_status'] ?? med['med_status'] ?? '-';

              String startDateStr = startDate is Timestamp
                  ? startDate.toDate().toLocal().toString().split(' ')[0]
                  : (startDate?.toString().split(' ')[0] ?? '-');
              String endDateStr = endDate is Timestamp
                  ? endDate.toDate().toLocal().toString().split(' ')[0]
                  : (endDate?.toString().split(' ')[0] ?? '-');

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Medication: $medName", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Dosage: $dosage"),
                      Text("Frequency: $frequency"),
                      Text("Start: $startDateStr"),
                      Text("End: $endDateStr"),
                      Text("Status: $medStatus"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit Medication',
                            onPressed: () async {
                              bool? updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MedicationPage(
                                    patientId: widget.patientId,
                                  ),
                                ),
                              );
                              // No need to refresh — StreamBuilder auto-updates
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Medication',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Medication?'),
                                  content: const Text('Are you sure you want to delete this medication?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('patients')
                                    .doc(widget.patientId)
                                    .collection('medications')
                                    .doc(medId)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Medication deleted')),
                                );
                                // No manual refresh needed
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'add_medication',
              onPressed: () async {
                bool? added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MedicationPage(
                      patientId: widget.patientId,
                    ),
                  ),
                );
                // StreamBuilder handles updates automatically
              },
              child: const Icon(Icons.add),
              tooltip: 'Add Medication',
            ),
          ),
        ],
      );
    },
  );
}

  Widget _buildHealthMetricsTab(List<dynamic> healthMetrics) {
  if (healthMetrics.isEmpty) {
    return const Center(child: Text('No health metrics found.'));
  }

  return ListView.builder(
    itemCount: healthMetrics.length,
    itemBuilder: (context, index) {
      final data = healthMetrics[index];
      final timestamp = data['dateRecorded'];
      DateTime? date;

      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.tryParse(timestamp);
      }

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: ListTile(
          title: Text(
            date != null ? 'Date: ${date.toLocal().toString().split(' ')[0]}' : 'Date: -',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Blood Pressure: ${data['bloodPressure'] ?? '-'}\n'
              'Heart Rate: ${data['heartRate'] ?? '-'} bpm\n'
              'Temperature: ${data['temperature'] ?? '-'} °C\n'
              'O2 Saturation: ${data['o2Saturation'] ?? '-'}%\n'
              'Blood Sugar: ${data['bloodSugarLevel'] ?? '-'} mg/dL',
            ),
          ),
        ),
      );
    },
  );
}
}

// import 'package:flutter/material.dart';
// import 'package:carebot/services/firestore_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'update_medical_history.dart'; // Make sure this import path is correct

// class PatientData extends StatefulWidget {
//   final String patientId;
//   final Map<String, dynamic>? patientData; // optional pre-fetched data

//   const PatientData({
//     Key? key,
//     required this.patientId,
//     this.patientData,
//   }) : super(key: key);

//   @override
//   State<PatientData> createState() => _PatientDataState();
// }

// class _PatientDataState extends State<PatientData> {
//   final FirestoreService firestoreService = FirestoreService();

//   Map<String, dynamic>? _patientData;
//   bool isLoading = true;
//   String? error;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.patientData != null) {
//       // Use passed data directly
//       _patientData = widget.patientData;
//       isLoading = false;
//     } else {
//       fetchPatientData();
//     }
//   }

//   Future<void> fetchPatientData() async {
//     try {
//       final docSnapshot = await firestoreService.getPatientDocument(widget.patientId);

//       final medicalHistory = await firestoreService.getMedicalHistoryOnce(widget.patientId);
//       final medications = await firestoreService.getMedicationsOnce(widget.patientId);
//       final healthMetrics = await firestoreService.getHealthMetricsOnce(widget.patientId);

//       setState(() {
//         _patientData = {
//           'patientDoc': docSnapshot.data(),
//           'medicalHistory': medicalHistory,
//           'medications': medications,
//           'healthMetrics': healthMetrics,
//         };
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _refreshMedicalHistory() async {
//     final medicalHistory = await firestoreService.getMedicalHistoryOnce(widget.patientId);
//     setState(() {
//       _patientData?['medicalHistory'] = medicalHistory;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (error != null) {
//       return Scaffold(
//         appBar: AppBar(title: Text('Patient Details')),
//         body: Center(child: Text('Error: $error')),
//       );
//     }

//     final patientInfo = _patientData?['patientDoc'] ?? {};
//     final medicalHistory = _patientData?['medicalHistory'] ?? [];
//     final medications = _patientData?['medications'] ?? [];
//     final healthMetrics = _patientData?['healthMetrics'] ?? [];

//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(patientInfo['name'] ?? 'Patient Details'),
//           bottom: TabBar(
//             tabs: const [
//               Tab(text: 'Medical History'),
//               Tab(text: 'Medications'),
//               Tab(text: 'Health Metrics'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildMedicalHistoryTab(medicalHistory),
//             _buildMedicationsTab(medications),
//             _buildHealthMetricsTab(healthMetrics),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMedicalHistoryTab(List<dynamic> medicalHistory) {
//     if (medicalHistory.isEmpty) {
//       return const Center(child: Text('No medical history found.'));
//     }

//     return ListView.builder(
//       itemCount: medicalHistory.length,
//       itemBuilder: (context, index) {
//         final item = medicalHistory[index];

//         String visitDateStr = '';
//         if (item['visitDate'] != null) {
//           if (item['visitDate'] is Timestamp) {
//             visitDateStr = (item['visitDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0];
//           } else {
//             visitDateStr = item['visitDate'].toString();
//           }
//         }

//         return Card(
//           margin: const EdgeInsets.all(8),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Allergies: ${item['allergies'] ?? '-'}'),
//                 const SizedBox(height: 4),
//                 Text('Blood Type: ${item['bloodType'] ?? '-'}'),
//                 const SizedBox(height: 4),
//                 Text('Chronic Disease: ${item['chronicDisease'] ?? '-'}'),
//                 const SizedBox(height: 4),
//                 Text('Doctor ID: ${item['doctorId'] ?? '-'}'),
//                 const SizedBox(height: 4),
//                 //Text('Medications: ${item['medications'] != null && item['medications'].isNotEmpty ? (item['medications'] as List).join(', ') : '-'}'),
//                 //const SizedBox(height: 4),
//                 Text('Notes: ${item['notes'] ?? '-'}'),
//                 const SizedBox(height: 4),
//                 Text('Visit Date: $visitDateStr'),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: IconButton(
//                     icon: const Icon(Icons.edit, color: Colors.blue),
//                     onPressed: () async {
//                       // Pass full MedicalHistory-like map including document ID
//                       bool? updated = await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => UpdateMedicalHistoryPage(
//                             patientId: widget.patientId,
//                             historyData: {
//                               'id': item['id'] ?? '', // assuming you have id stored here
//                               'bloodType': item['bloodType'],
//                               'allergies': item['allergies'],
//                               'chronicDisease': item['chronicDisease'],
//                               'notes': item['notes'],
//                               'visitDate': item['visitDate'],
//                               'doctorId': item['doctorId'],
//                               'medications': item['medications'],
//                             }, history: {},
//                           ),
//                         ),
//                       );

//                       if (updated == true) {
//                         await _refreshMedicalHistory();
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMedicationsTab(List<dynamic> medications) {
//     if (medications.isEmpty) {
//       return const Center(child: Text('No medications found.'));
//     }

//     return ListView.builder(
//       itemCount: medications.length,
//       itemBuilder: (context, index) {
//         final med = medications[index];
//         return ListTile(
//           title: Text(med['med_name'] ?? 'Medication'),
//           subtitle: Text('Dosage: ${med['dosage'] ?? 'N/A'}'),
//         );
//       },
//     );
//   }

//   Widget _buildHealthMetricsTab(List<dynamic> healthMetrics) {
//     if (healthMetrics.isEmpty) {
//       return const Center(child: Text('No health metrics found.'));
//     }

//     return ListView.builder(
//       itemCount: healthMetrics.length,
//       itemBuilder: (context, index) {
//         final metric = healthMetrics[index];
//         return ListTile(
//           title: Text('Date: ${metric['dateRecorded'] ?? ''}'),
//           subtitle: Text(
//               'BP: ${metric['bloodPressure'] ?? '-'} | HR: ${metric['heartRate'] ?? '-'} | Temp: ${metric['temperature'] ?? '-'}'),
//         );
//       },
//     );
//   }
// }