import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteController extends ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => _notes;

  // Add a text note with optional location
  void addTextNote(String title, String content, {double? latitude, double? longitude}) {
  // Debugging output
  print('Adding Text Note');
  print('Title: $title');
  print('Latitude: $latitude, Longitude: $longitude');  // Log coordinates

  _notes.add(Note(
    id: DateTime.now().toString(),
    title: title,
    content: content,
    type: 'text',
    latitude: latitude,
    longitude: longitude,
  ));
  notifyListeners();
}


  // Add an audio note with optional location
  void addAudioNote(String title, String filePath, {double? latitude, double? longitude}) {
  print('Adding Audio Note');
  print('Title: $title');
  print('Latitude: $latitude, Longitude: $longitude');  // Log coordinates
    _notes.add(Note(
      id: DateTime.now().toString(),
      title: title,
      type: 'audio',
      filePath: filePath,
      latitude: latitude,
      longitude: longitude,
    ));
    notifyListeners();
  }

  // Add a picture note with optional location
  void addPictureNote(String title, String filePath, {double? latitude, double? longitude}) {
  print('Adding Picture Note');
  print('Title: $title');
  print('Latitude: $latitude, Longitude: $longitude');  // Log coordinates
    _notes.add(Note(
      id: DateTime.now().toString(),
      title: title,
      type: 'image',
      filePath: filePath,
      latitude: latitude,
      longitude: longitude,
    ));
    notifyListeners();
  }

  // Delete a note by ID
  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
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
      notifyListeners();
    }
  }
}
