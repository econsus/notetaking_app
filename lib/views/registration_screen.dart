// lib/views/registration_screen.dart
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class RegistrationScreen extends StatelessWidget {
  final AuthController _authController = AuthController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var user = await _authController.register(emailController.text, passwordController.text);
                if (user != null) {
                  Navigator.pop(context); // Go back to login
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
