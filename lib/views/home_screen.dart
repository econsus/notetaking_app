// home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/note_controller.dart';
import '../models/note.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart'; // Import the LoginScreen

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final noteController = Provider.of<NoteController>(context);
    final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize FirebaseAuth

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: () async {
              await _auth.signOut(); // Sign out from Firebase
              // Navigate back to the login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showNoteDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: noteController.notes.length,
        itemBuilder: (context, index) {
          final note = noteController.notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            onTap: () {
              _showNoteDialog(context, note: note);
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                noteController.deleteNote(note.id);
              },
            ),
          );
        },
      ),
    );
  }

  void _showNoteDialog(BuildContext context, {Note? note}) {
    final titleController = TextEditingController(text: note?.title);
    final contentController = TextEditingController(text: note?.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (note == null) {
                  // Add note
                  Provider.of<NoteController>(context, listen: false).addNote(
                    titleController.text,
                    contentController.text,
                  );
                } else {
                  // Edit note
                  Provider.of<NoteController>(context, listen: false).updateNote(
                    note.id,
                    titleController.text,
                    contentController.text,
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text(note == null ? 'Add' : 'Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
