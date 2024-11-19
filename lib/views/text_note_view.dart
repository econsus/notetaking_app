// views/text_note_view.dart
import 'package:flutter/material.dart';
import '../models/note.dart';

class TextNoteView extends StatelessWidget {
  final Note note;

  TextNoteView({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(note.content ?? 'No content available'),
      ),
    );
  }
}
