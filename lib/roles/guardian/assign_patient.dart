import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import for StreamBuilder
import '../../services/firestore_service.dart';

class AssignPatientPage extends StatefulWidget {
  final String guardianId;

  const AssignPatientPage({Key? key, required this.guardianId}) : super(key: key);

  @override
  _AssignPatientPageState createState() => _AssignPatientPageState();
}

class _AssignPatientPageState extends State<AssignPatientPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final int maxPatients = 4;
  List<TextEditingController> _emailControllers = [TextEditingController()];
  bool _isSaving = false;
  List<Map<String, String>> _alreadyAssignedPatients = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignedPatients();
  }

  @override
  void dispose() {
    for (var c in _emailControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchAssignedPatients() async {
    final assigned = await _firestoreService.getAssignedPatientsForGuardian(widget.guardianId);

    List<Map<String, String>> patientsWithNames = [];

    for (var p in assigned) {
      String name = '';
      if (p.uid.isNotEmpty) {
        final userDoc = await _firestoreService.getUserByUid(p.uid);
        name = userDoc?['name'] ?? '';
      }
      patientsWithNames.add({
        'name': name,
        'email': p.email,
      });
    }

    setState(() {
      _alreadyAssignedPatients = patientsWithNames;
    });
  }

  void _addPatientField() {
    if (_emailControllers.length < maxPatients) {
      setState(() {
        _emailControllers.add(TextEditingController());
      });
    }
  }

  Future<void> _assignPatients() async {
    if (widget.guardianId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardian ID is empty!')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      List<String> emails = _emailControllers
          .map((c) => c.text.trim())
          .where((email) => email.isNotEmpty)
          .toList();

      if (emails.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter at least one patient email.')),
        );
        setState(() => _isSaving = false);
        return;
      }

      final alreadyAssignedEmails = _alreadyAssignedPatients.map((p) => p['email']).toList();
      final alreadyAssigned = emails.where((email) => alreadyAssignedEmails.contains(email)).toList();
      if (alreadyAssigned.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Already assigned: ${alreadyAssigned.join(", ")}')),
        );
        setState(() => _isSaving = false);
        return;
      }

      await _firestoreService.assignMultiplePatientsToGuardian(
        guardianId: widget.guardianId,
        patientEmails: emails,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patients assigned successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign patients: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Patients")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_alreadyAssignedPatients.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Already Assigned Patients:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ..._alreadyAssignedPatients.map(
                    (p) => Text('${p['name']} (${p['email']})'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Assigned Patients",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    const SizedBox(height: 8),
    StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('guardians')
          .doc(widget.guardianId)
          .collection('assignedPatients')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No assigned patients');
        }

        final assignedPatients = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assignedPatients.length,
          itemBuilder: (context, index) {
            final patient = assignedPatients[index];
            final email = patient['email'] ?? 'No email';
            final uid = patient['uid'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text(email),
                    subtitle: const Text('Loading name...'),
                  );
                }
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return ListTile(
                    title: Text(email),
                    subtitle: Text('UID: $uid'),
                  );
                }

                final userDoc = userSnapshot.data!;
                final name = userDoc['name'] ?? 'No name';

                return ListTile(
                  title: Text(name),
                  subtitle: Text(email),
                );
              },
            );
          },
        );
      },
    ),
    const SizedBox(height: 16), // some space below this section
  ],
),



            Expanded(
              child: ListView.builder(
                itemCount: _emailControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: _emailControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Patient Email ${index + 1}',
                        suffixIcon: (index == _emailControllers.length - 1 &&
                                _emailControllers.length < maxPatients)
                            ? IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addPatientField,
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  );
                },
              ),
            ),
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _assignPatients,
                    child: const Text("Assign"),
                  ),
          ],
        ),
      ),
    );
  }
}