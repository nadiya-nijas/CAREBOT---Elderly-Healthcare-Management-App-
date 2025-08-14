import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/health_metrics_model.dart';

class HealthMetricsPage extends StatelessWidget {
  final String patientId;

  const HealthMetricsPage({Key? key, required this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metricsRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('healthMetrics');

    return Scaffold(
      appBar: AppBar(title: const Text('Health Metrics')),
      body: StreamBuilder<QuerySnapshot>(
        stream: metricsRef.orderBy('dateRecorded', descending: true).limit(1).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          final metric = docs.isNotEmpty
              ? HealthMetric.fromMap(docs.first.id, docs.first.data() as Map<String, dynamic>)
              : HealthMetric(
                  id: '',
                  height: 0.0,
                  weight: 0.0,
                  temperature: 0.0,
                  bloodPressure: 'N/A',
                  heartRate: 0,
                  o2Saturation: 0.0,
                  bloodSugarLevel: 0.0,
                  dateRecorded: DateTime.now(),
                );

          return _buildMetricsUI(metric);
        },
      ),
    );
  }

  Widget _buildMetricsUI(HealthMetric metric) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildMetricTile('Height', '${metric.height} cm'),
          _buildMetricTile('Weight', '${metric.weight} kg'),
          _buildMetricTile('Temperature', '${metric.temperature} °C'),
          _buildMetricTile('Blood Pressure', metric.bloodPressure),
          _buildMetricTile('Heart Rate', '${metric.heartRate} bpm'),
          _buildMetricTile('O2 Saturation', '${metric.o2Saturation}%'),
          _buildMetricTile('Blood Sugar', '${metric.bloodSugarLevel} mg/dL'),
          _buildMetricTile('Last Updated', metric.dateRecorded.toLocal().toString().split(' ')[0]),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
