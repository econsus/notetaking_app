// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../views/login_screen.dart';
import 'controllers/note_controller.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => NoteController(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), // Show login screen on startup
    );
  }
}
