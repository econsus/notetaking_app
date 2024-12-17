import 'dart:convert';
import '../repository/note_repository.dart';
import 'package:flutter/material.dart';
import '../models/note.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';  // Added for connectivity check
import 'package:http/http.dart' as http;

class NoteController extends ChangeNotifier {
  final NoteRepository _repository = NoteRepository();
  final List<Note> _notes = [];
  List<Note> get notes => _notes;

  static const String _notesKey = 'notes';

  // Track the network status (online/offline)
  bool _isOnline = false;

  // Fetch notes based on connectivity
  Future<void> fetchNotes() async {
    // Check connectivity before fetching
    await _checkConnectivity();
    print("Online Status : ");
    print(_isOnline);
    if (_isOnline) {
      // Online: Fetch from Firebase
      final fetchedNotes = await _repository.fetchNotes();
      _notes.clear();
      _notes.addAll(fetchedNotes);
    } else {
      // Offline: Fetch from local storage
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_notesKey);
      if (notesJson != null) {
        final List<dynamic> notesList = jsonDecode(notesJson);
        _notes.clear();
        _notes.addAll(notesList.map((note) => Note.fromMap(note)).toList());
      }
    }
    notifyListeners();
  }

  // Save notes based on connectivity
  Future<void> saveNotes() async {
    // Check connectivity before saving
    await _checkConnectivity();
    print("Online Status : ");
    print(_isOnline);
    if (_isOnline) {
      // Online: Save to Firebase
      await _repository.saveNotes(_notes);
      print("Repository saveNotes ran");
    } else {
      // Offline: Save to local storage
      final prefs = await SharedPreferences.getInstance();
      final notesJson = jsonEncode(_notes.map((note) => note.toMap()).toList());
      await prefs.setString(_notesKey, notesJson);
      print("Local Database saveNotes ran");
    }
  }

  // Add a text note with optional location
  void addTextNote(String title, String content, {double? latitude, double? longitude}) {
    _notes.add(Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      type: 'text',
      latitude: latitude,
      longitude: longitude,
    ));
    saveNotes();
    notifyListeners();
    
  }

  // Add an audio note with optional location
  void addAudioNote(String title, String filePath, {double? latitude, double? longitude}) {
    _notes.add(Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: 'audio',
      filePath: filePath,
      latitude: latitude,
      longitude: longitude,
    ));
    saveNotes();
    notifyListeners();
  }

  // Add a picture note with optional location
  void addPictureNote(String title, String filePath, {double? latitude, double? longitude}) {
    _notes.add(Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: 'image',
      filePath: filePath,
      latitude: latitude,
      longitude: longitude,
    ));
    saveNotes();
    notifyListeners();
  }

  // Delete a note by ID
  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    saveNotes();
    notifyListeners();
  }

  // Update an existing note (generic fields)
  void updateNote(String id, String title, {String? content, String? filePath, double? latitude, double? longitude}) {
    final noteIndex = _notes.indexWhere((note) => note.id == id);
    if (noteIndex != -1) {
      final note = _notes[noteIndex];
      _notes[noteIndex] = Note(
        id: note.id,
        title: title,
        content: content ?? note.content,
        filePath: filePath ?? note.filePath,
        type: note.type,
        latitude: latitude ?? note.latitude,
        longitude: longitude ?? note.longitude,
      );
      saveNotes();
      notifyListeners();
    }
  }

  // Specific method for updating text notes
  void updateTextNote(String id, String updatedTitle, String updatedContent, {double? latitude, double? longitude}) {
    final noteIndex = _notes.indexWhere((note) => note.id == id);
    if (noteIndex != -1) {
      final note = _notes[noteIndex];
      _notes[noteIndex] = Note(
        id: note.id,
        title: updatedTitle,
        content: updatedContent,
        type: 'text',
        latitude: latitude ?? note.latitude,
        longitude: longitude ?? note.longitude,
      );
      saveNotes();
      notifyListeners();
    }
  }

  // Private method to check connectivity status
  // Private method to check connectivity status
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    // If there's no connectivity at all
    if (connectivityResult == ConnectivityResult.none) {
      _isOnline = false;
      print("Offline mode: Using local storage.");
    } else {
      // Check for internet access by making a request to a known public server (Google DNS)
      final isConnectedToInternet = await _checkInternetConnection();
      if (isConnectedToInternet) {
        _isOnline = true;
        print("Online mode: Using Firebase Firestore.");
      } else {
        _isOnline = false;
        print("Offline mode: Using local storage.");
      }
    }
  }

    // Method to check if device can access the internet by pinging a known server
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await http.get(Uri.parse('https://www.google.com'));
      return result.statusCode == 200; // If HTTP request is successful, internet is accessible
    } catch (e) {
      return false; // If there was an error, no internet access
    }
  }
}
