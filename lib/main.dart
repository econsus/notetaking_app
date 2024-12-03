import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login_using_firebase/views/home_screen.dart';
import 'package:provider/provider.dart';
import '/controllers/note_controller.dart';
import '/controllers/location_controller.dart';
import '/views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NoteController()),
        ChangeNotifierProvider(create: (context) => LocationController()),
      ],
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
      home: HomeScreen(), // Show login screen on startup
    );
  }
}
