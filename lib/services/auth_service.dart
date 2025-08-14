import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signUp(String email, String password, String name, String role) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = result.user;

    if (user != null) {
      // Create AppUser model instance
      AppUser appUser = AppUser(
        uid: user.uid,
        name: name,
        email: email,
        role: role,
      );

      // Save user details in 'users' collection
      await FirestoreService().createUser(appUser);

      // Create initial role-based document with timestamp
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final timestamp = Timestamp.now();

      if (role == 'doctor') {
        await db.collection('doctors').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': timestamp,
        });
      } else if (role == 'patient') {
        await db.collection('patients').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': timestamp,
        });
      } else if (role == 'guardian') {
        await db.collection('guardians').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': timestamp,
        });
      }
    }
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }
}