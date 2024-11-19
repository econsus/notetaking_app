// lib/controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register a user
  Future<UserModel?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      return UserModel(uid: user?.uid, email: user?.email);
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Login a user
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      return UserModel(uid: user?.uid, email: user?.email);
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Logout a user
  Future<void> logout() async {
    await _auth.signOut();
  }
}
