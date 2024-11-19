// controllers/note_controller.dart
import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteController extends ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => _notes;

  void addTextNote(String title, String content) {
  _notes.add(
    Note(
      id: DateTime.now().toString(),
      title: title,
      content: content,
      type: 'text',
    ),
  );
  notifyListeners();
}

  void addAudioNote(String title, String filePath) {
  final newNote = Note(
    id: DateTime.now().toString(),
    title: title,
    type: 'audio',
    filePath: filePath,
  );
  notes.add(newNote);
  notifyListeners();
}


void addPictureNote(String title, String filePath) {
  _notes.add(
    Note(
      id: DateTime.now().toString(),
      title: title,
      filePath: filePath,
      type: 'image',
    ),
  );
  notifyListeners();
}


  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  void updateNote(String id, String title, {String? content, String? filePath}) {
    final noteIndex = _notes.indexWhere((note) => note.id == id);
    if (noteIndex != -1) {
      final note = _notes[noteIndex];
      _notes[noteIndex] = Note(
        id: note.id,
        title: title,
        content: content ?? note.content,
        filePath: filePath ?? note.filePath,
        type: note.type,
      );
      notifyListeners();
    }
  }

  void updateTextNote(String id, String updatedTitle, String updatedContent) {
  final noteIndex = notes.indexWhere((note) => note.id == id);
  if (noteIndex != -1) {
    notes[noteIndex] = Note(
      id: id,
      title: updatedTitle,
      content: updatedContent,
      type: 'text',
    );
    notifyListeners();
  }
}
}
