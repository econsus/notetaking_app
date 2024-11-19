// views/voice_note_view.dart
import 'package:flutter/material.dart';

import '../models/note.dart';

class VoiceNoteView extends StatelessWidget {
  final Note note;

  VoiceNoteView({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Voice Note'),
            ElevatedButton(
              onPressed: () {
                // Play the voice recording (add a package like flutter_sound or just_audio)
              },
              child: Text('Play Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
