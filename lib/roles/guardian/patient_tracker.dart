import 'package:flutter/material.dart';
import 'package:carebot/roles/guardian/health_metric_dialog.dart';
import 'package:carebot/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuardianPatientTrackerPage extends StatefulWidget {
  final String guardianId;

  const GuardianPatientTrackerPage({Key? key, required this.guardianId}) : super(key: key);

  @override
  State<GuardianPatientTrackerPage> createState() => _GuardianPatientTrackerPageState();
}

class _GuardianPatientTrackerPageState extends State<GuardianPatientTrackerPage> {
  final FirestoreService firestoreService = FirestoreService();

  List<Map<String, dynamic>> assignedPatients = [];
  String? selectedPatientId;

  Map<String, dynamic>? patientData;
  bool isLoadingData = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAssignedPatients();
  }

  Future<void> fetchAssignedPatients() async {
    if (widget.guardianId.isEmpty) {
      setState(() {
        error = 'Guardian ID is empty!';
      });
      return;
    }

    try {
      final assignedSnapshot = await FirebaseFirestore.instance
          .collection('guardians')
          .doc(widget.guardianId)
          .collection('assignedPatients')
          .get();

      List<Map<String, dynamic>> patientsWithNames = [];

      for (var doc in assignedSnapshot.docs) {
        final patientId = doc.id;

        var patientDoc = await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .get();

        if (patientDoc.exists) {
          patientsWithNames.add({
            'id': patientId,
            'name': patientDoc.data()?['name'] ?? 'Unnamed Patient',
          });
        }
      }

      setState(() {
        assignedPatients = patientsWithNames;
        error = null;
      });
    } catch (e) {
      print("Error fetching assigned patients from subcollection: $e");
      setState(() {
        error = e.toString();
      });
    }
  }

  Future<void> fetchPatientData(String patientId) async {
    setState(() {
      isLoadingData = true;
      error = null;
    });

    try {
      final docSnapshot = await firestoreService.getPatientDocument(patientId);

      final medicalHistory = await firestoreService.getMedicalHistoryOnce(patientId);
      final medications = await firestoreService.getMedicationsOnce(patientId);
      final healthMetrics = await firestoreService.getHealthMetricsOnce(patientId);
      final mentalHealth = await firestoreService.getMentalHealthOnce(patientId);
      final appointments = await firestoreService.getAppointmentsOnce(patientId);

      setState(() {
        patientData = {
          'patientDoc': docSnapshot.data(),
          'medicalHistory': medicalHistory,
          'medications': medications,
          'healthMetrics': healthMetrics,
          'mentalHealth': mentalHealth,
          'appointments': appointments,
        };
        isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text("Patient Tracker")),
        body: Center(child: Text("Error: $error")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Patient Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            assignedPatients.isEmpty
                ? Text('No assigned patients found.')
                : DropdownButton<String>(
                    value: selectedPatientId,
                    hint: Text('Select Patient'),
                    isExpanded: true,
                    items: assignedPatients
                        .map((p) => DropdownMenuItem<String>(
                              value: p['id'],
                              child: Text(p['name']),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedPatientId = val;
                        patientData = null;
                      });
                      if (val != null) fetchPatientData(val);
                    },
                  ),
            SizedBox(height: 16),
            if (isLoadingData)
              CircularProgressIndicator()
            else if (patientData != null)
              Expanded(
                child: PatientTabs(
                  patientData: patientData!,
                  patientId: selectedPatientId!,
                  guardianId: widget.guardianId,
                  assignedPatients: assignedPatients,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PatientTabs extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final String patientId;
  final String guardianId;
  final List<Map<String, dynamic>> assignedPatients;

  const PatientTabs({
    Key? key,
    required this.patientData,
    required this.patientId,
    required this.guardianId,
    required this.assignedPatients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patientInfo = patientData['patientDoc'] ?? {};
    final medicalHistory = patientData['medicalHistory'] ?? [];
    final medications = patientData['medications'] ?? [];
    final healthMetrics = patientData['healthMetrics'] ?? [];
    final mentalHealth = patientData['mentalHealth'] ?? [];

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(patientInfo['name'] ?? 'Patient Details'),
          bottom: TabBar(
            isScrollable: true,
            tabs: const [
              Tab(text: 'Medical History'),
              Tab(text: 'Medications'),
              Tab(text: 'Health Metrics'),
              Tab(text: 'Mental Health'),
              Tab(text: 'Appointments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MedicalHistoryTab(medicalHistory: medicalHistory, patientId: patientId),
            MedicationsTab(medications: medications),
            HealthMetricsTab(patientId: patientId),
            MentalHealthTab(mentalHealth: mentalHealth),
            AppointmentsTab(
              guardianId: guardianId,
              assignedPatients: assignedPatients,
              patientId: patientId,
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalHistoryTab extends StatelessWidget {
  final List<dynamic> medicalHistory;
  final String patientId;

  const MedicalHistoryTab({Key? key, required this.medicalHistory, required this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (medicalHistory.isEmpty) {
      return Center(child: Text('No medical history found.'));
    }

    return ListView.builder(
      itemCount: medicalHistory.length,
      itemBuilder: (context, index) {
        final item = medicalHistory[index];

        String visitDateStr = '';
        if (item['visitDate'] != null) {
          if (item['visitDate'] is Timestamp) {
            visitDateStr = (item['visitDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0];
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
                SizedBox(height: 4),
                Text('Blood Type: ${item['bloodType'] ?? '-'}'),
                SizedBox(height: 4),
                Text('Chronic Disease: ${item['chronicDisease'] ?? '-'}'),
                SizedBox(height: 4),
                Text('Doctor ID: ${item['doctorId'] ?? '-'}'),
                SizedBox(height: 4),
                Text('Notes: ${item['notes'] ?? '-'}'),
                SizedBox(height: 4),
                Text('Visit Date: $visitDateStr'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MedicationsTab extends StatelessWidget {
  final List<dynamic> medications;

  const MedicationsTab({Key? key, required this.medications}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (medications.isEmpty) return Center(child: Text('No medications found.'));

    return ListView.builder(
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final med = medications[index];

        return Card(
          margin: const EdgeInsets.all(8),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med['Med_Name'] ?? 'Medication',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text('Dosage: ${med['Dosage'] ?? 'N/A'}'),
                Text('Status: ${med['Med_status'] ?? 'N/A'}'),
                Text('Frequency: ${(med['Frequency'] as List<dynamic>?)?.join(", ") ?? 'N/A'}'),
                Text('Start Date: ${med['StartDate'] != null ? (med['StartDate'] as Timestamp).toDate().toString().split(' ')[0] : 'N/A'}'),
                Text('End Date: ${med['EndDate'] != null ? (med['EndDate'] as Timestamp).toDate().toString().split(' ')[0] : 'N/A'}'),
                Text('Doctor ID: ${med['Doctor_ID'] ?? 'N/A'}'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HealthMetricsTab extends StatefulWidget {
  final String patientId;

  const HealthMetricsTab({Key? key, required this.patientId}) : super(key: key);

  @override
  State<HealthMetricsTab> createState() => _HealthMetricsTabState();
}

class _HealthMetricsTabState extends State<HealthMetricsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .collection('healthMetrics')
            .orderBy('dateRecorded', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final metrics = snapshot.data!.docs;

          if (metrics.isEmpty) {
            return Center(child: Text('No health metrics found.'));
          }

          return ListView.builder(
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              final data = metrics[index].data() as Map<String, dynamic>;
              final date = (data['dateRecorded'] as Timestamp?)?.toDate();

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${_formatDate(date)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text('Blood Pressure: ${data['bloodPressure'] ?? '-'}'),
                      Text('Heart Rate: ${data['heartRate'] ?? '-'} bpm'),
                      Text('Temperature: ${data['temperature'] ?? '-'} °C'),
                      if (data['o2Saturation'] != null) Text('O₂ Saturation: ${data['o2Saturation']} %'),
                      if (data['bloodSugarLevel'] != null) Text('Blood Sugar: ${data['bloodSugarLevel']} mg/dL'),
                      if (data['weight'] != null) Text('Weight: ${data['weight']} kg'),
                      if (data['height'] != null) Text('Height: ${data['height']} cm'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddHealthMetricDialog(patientId: widget.patientId),
        ),
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class MentalHealthTab extends StatelessWidget {
  final List<dynamic> mentalHealth;

  const MentalHealthTab({Key? key, required this.mentalHealth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mentalHealth.isEmpty) return Center(child: Text('No mental health records found.'));
    return ListView.builder(
      itemCount: mentalHealth.length,
      itemBuilder: (context, index) {
        final record = mentalHealth[index];
        return ListTile(
          title: Text('Mood Rating: ${record['moodRating'] ?? '-'}'),
          subtitle: Text('Stress Level: ${record['stressLevel'] ?? '-'} | Sleep Quality: ${record['sleepQuality'] ?? '-'}'),
        );
      },
    );
  }
}

class AppointmentsTab extends StatelessWidget {
  final String guardianId;
  final List<Map<String, dynamic>> assignedPatients;
  final String patientId;

  const AppointmentsTab({
    Key? key,
    required this.guardianId,
    required this.assignedPatients,
    required this.patientId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appointmentsRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('appointments')
        .orderBy('apptDate', descending: false);

    return Column(
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text('Create Appointment'),
          onPressed: assignedPatients.isEmpty
              ? null
              : () async {
                  await showDialog(
                    context: context,
                    builder: (context) => CreateAppointmentDialog(
                      guardianId: guardianId,
                      patients: assignedPatients,
                    ),
                  );
                },
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: appointmentsRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No appointments found.'));
              }
              final docs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
  final appt = docs[index].data() as Map<String, dynamic>;
  final doctorId = appt['doctorId'] ?? '-';
  final apptDate = appt['apptDate'] is Timestamp
      ? (appt['apptDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0]
      : appt['apptDate']?.toString() ?? '-';

  return FutureBuilder<Map<String, dynamic>?>(
    future: FirestoreService().getUserByUid(doctorId),
    builder: (context, doctorSnapshot) {
      String doctorName = doctorId;
      if (doctorSnapshot.hasData && doctorSnapshot.data != null) {
        doctorName = doctorSnapshot.data!['name'] ?? doctorId;
      }
      return ListTile(
        title: Text(
          'Date: $apptDate',
        ),
        subtitle: Text(
          'Doctor: $doctorName | Type: ${appt['apptType'] ?? '-'} | Status: ${appt['apptStatus'] ?? '-'}',
        ),
      );
    },
  );
}
              );
            },
          ),
        ),
      ],
    );
  }
}

class CreateAppointmentDialog extends StatefulWidget {
  final String guardianId;
  final List<Map<String, dynamic>> patients;

  const CreateAppointmentDialog({
    Key? key,
    required this.guardianId,
    required this.patients,
  }) : super(key: key);

  @override
  State<CreateAppointmentDialog> createState() => _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState extends State<CreateAppointmentDialog> {
  String? selectedPatientId;
  String? selectedDoctorId;
  DateTime? selectedDate;
  String? selectedType;
  String? selectedStatus = 'Scheduled';
  String? selectedTimeSlot;
  bool isSaving = false;
  List<Map<String, dynamic>> doctors = [];

  final List<String> apptTypes = ['Consultation', 'Checkup', 'Surgery'];
  final List<String> apptStatuses = ['Scheduled', 'Completed', 'Cancelled'];
  final List<String> timeSlots = [
    '09:00-10:00',
    '10:00-11:00',
    '11:00-12:00',
    '14:00-15:00',
    '15:00-16:00',
    '16:00-17:00',
  ];

  @override
  void initState() {
    super.initState();
    fetchDoctors();
    if (widget.patients.isNotEmpty) {
      selectedPatientId = widget.patients.first['id'];
    }
  }

  Future<void> fetchDoctors() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .get();
    setState(() {
      doctors = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'] ?? 'Doctor',
                'email': doc['email'] ?? '',
              })
          .toList();
      if (doctors.isNotEmpty) selectedDoctorId = doctors.first['id'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Appointment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedPatientId,
              items: widget.patients
                  .map((p) => DropdownMenuItem<String>(
                        value: p['id'] as String,
                        child: Text((p['name'] ?? p['id']).toString()),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedPatientId = val),
              decoration: InputDecoration(labelText: 'Patient'),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedDoctorId,
              items: doctors
                  .map((d) => DropdownMenuItem<String>(
                        value: d['id'] as String,
                        child: Text((d['name'] ?? d['id']).toString()),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedDoctorId = val),
              decoration: InputDecoration(labelText: 'Doctor'),
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text(selectedDate == null
                  ? 'Select Date'
                  : selectedDate!.toLocal().toString().split(' ')[0]),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
            ),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: apptTypes
                  .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => setState(() => selectedType = val),
              decoration: InputDecoration(labelText: 'Appointment Type'),
            ),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: apptStatuses
                  .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => selectedStatus = val),
              decoration: InputDecoration(labelText: 'Status'),
            ),
            DropdownButtonFormField<String>(
              value: selectedTimeSlot,
              items: timeSlots
                  .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => selectedTimeSlot = val),
              decoration: InputDecoration(labelText: 'Time Slot'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isSaving
              ? null
              : () async {
                  if (selectedPatientId == null ||
                      selectedDoctorId == null ||
                      selectedDate == null ||
                      selectedType == null ||
                      selectedStatus == null ||
                      selectedTimeSlot == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all fields')));
                    return;
                  }
                  setState(() => isSaving = true);
                  await FirestoreService().createAppointment(
                    patientId: selectedPatientId!,
                    doctorId: selectedDoctorId!,
                    apptDate: selectedDate!,
                    apptType: selectedType!,
                    apptStatus: selectedStatus!,
                    timeSlot: selectedTimeSlot!,
                    createdBy: widget.guardianId,
                  );
                  setState(() => isSaving = false);
                  Navigator.pop(context, true);
                },
          child: isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Create'),
        ),
      ],
    );
  }
}