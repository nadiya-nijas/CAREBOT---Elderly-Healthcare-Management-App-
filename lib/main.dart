import 'package:carebot/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'auth/login_page.dart';
import 'auth/signup_page.dart';

import 'roles/doctor/dashboard.dart';
import 'roles/guardian/medications_edit_page.dart';
import 'roles/patient/patient_dashboard.dart';
import 'roles/guardian/guardian_dashboard.dart';

import 'roles/patient/health_metrics_page.dart';

import 'roles/patient/medications_page.dart';
import 'roles/patient/mental_health_page.dart';
import 'roles/patient/appointments_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CareBotApp());
}

class CareBotApp extends StatelessWidget {
  const CareBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareBot',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/dashboard': (context) => const DoctorDashboard(),
        // '/dashboard': (context) => DoctorDashboard(doctorId: ''),
        '/patientDashboard': (context) => PatientDashboard(),
        '/guardianDashboard': (context) => GuardianDashboard(guardianId: '',),
        '/healthMetrics': (context) => HealthMetricsPage(patientId: ''),
        '/appointmentsPage': (context) => AppointmentPage(patientId: ''),
        // '/medicationPage': (context) => MedicationPage(patientId: ''),
        '/medicationPage': (context) => MedicationViewPage(patientId: ''),
        '/medicationEditPage': (context) => MedicationPage(patientId: ''),
        '/mentalHealth': (context) => MentalHealthPage(patientId: ''),
      },
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// import 'auth/login_page.dart';
// import 'auth/signup_page.dart';
// import 'roles/doctor/dashboard.dart';
// import 'package:carebot/roles/patient/patient_dashboard.dart';

// import 'roles/guardian/guardian_dashboard.dart';
// import '../roles/patient/health_metrics_page.dart';
// import '../roles/patient/update_health_metrics.dart';

// import '../roles/patient/medication_page.dart';
// import '../roles/patient/mental_health_page.dart';


// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MyApp());
// }


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       initialRoute: '/login',
//       routes: {
//         '/login': (context) => LoginPage(),
//         '/signup': (context) => SignupPage(),
//         '/doctorDashboard': (context) => DoctorDashboard(),
//         '/patientDashboard': (context) => PatientDashboard(),
//         '/guardianDashboard': (context) => GuardianDashboard(),
//       },
//     );
//   }

 
// }


















