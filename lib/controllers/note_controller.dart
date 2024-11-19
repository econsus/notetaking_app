// controllers/note_controller.dart
import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteController with ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  void addNote(String title, String content) {
    final newNote = Note(
      id: DateTime.now().toString(), // Use timestamp as a unique ID
      title: title,
      content: content,
    );
    _notes.add(newNote);
    notifyListeners();
  }

  void updateNote(String id, String title, String content) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index >= 0) {
      _notes[index] = Note(id: id, title: title, content: content);
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}
