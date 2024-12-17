import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/note.dart';

class NoteRepository {
  static const String _notesKey = 'notes';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Check connectivity
Future<bool> isOnline() async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    print('Connectivity result: $connectivityResult');  // Debugging the result
    
    // Check if the connectivity result contains mobile or wifi
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  } catch (e) {
    print('Error checking connectivity: $e');
    return false;
  }
}


  // Fetch notes
  Future<List<Note>> fetchNotes() async {
    try {
      if (await isOnline()) {
        // Fetch all notes from Firestore
        final snapshot = await _firestore.collection('notes').get();
        if (snapshot.docs.isNotEmpty) {
          print('Fetched ${snapshot.docs.length} notes');
          return snapshot.docs.map((doc) => Note.fromMap(doc.data())).toList();
        } else {
          print('No notes found');
          return [];
        }
      } else {
        // Fetch from local storage
        final prefs = await SharedPreferences.getInstance();
        final notesJson = prefs.getString(_notesKey);
        if (notesJson != null) {
          final List<dynamic> notesList = jsonDecode(notesJson);
          return notesList.map((note) => Note.fromMap(note)).toList();
        }
        return [];
      }
    } catch (e) {
      print('Error fetching notes: $e');
      return [];
    }
  }

// Save notes to local or online storage
Future<void> saveNotes(List<Note> notes) async {
  try {
    print('Checking connectivity...');
    bool onlineStatus = await isOnline();
    print('Online status: $onlineStatus'); // Log the result of isOnline

    if (onlineStatus) {
      try {
        WriteBatch batch = _firestore.batch();
        for (var note in notes) {
          DocumentReference docRef = _firestore.collection('notes').doc(note.id);
          print('Saving note: ${note.toMap()}');
          batch.set(docRef, note.toMap());
        }
        await batch.commit();
        print('Notes saved to Firestore');
      } catch (e) {
        print('Error saving notes to Firestore: $e');
      }
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        final notesJson = jsonEncode(notes.map((note) => note.toMap()).toList());
        await prefs.setString(_notesKey, notesJson);
        print('Notes saved locally to SharedPreferences');
      } catch (e) {
        print('Error saving notes locally: $e');
      }
    }

    // Update local storage after saving to Firebase
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = jsonEncode(notes.map((note) => note.toMap()).toList());
      await prefs.setString(_notesKey, notesJson);
      print('Local storage updated after save');
    } catch (e) {
      print('Error updating local storage: $e');
    }
  } catch (e) {
    print('Error during saveNotes: $e');
  }
}

  // Sync local notes to Firebase
  Future<void> syncLocalToFirebase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_notesKey);
      if (notesJson != null && notesJson.isNotEmpty) {
        final List<dynamic> notesList = jsonDecode(notesJson);
        final notes = notesList.map((note) => Note.fromMap(note)).toList();
        for (var note in notes) {
          try {
            // Create a unique document ID for each note
            await _firestore.collection('notes').doc(note.id).set(note.toMap());
            print('Note synced to Firestore: ${note.toMap()}');
          } catch (e) {
            print('Error syncing note ${note.id} to Firestore: $e');
          }
        }
      } else {
        print('No local notes found to sync');
      }
    } catch (e) {
      print('Error during syncLocalToFirebase: $e');
    }
  }
}
