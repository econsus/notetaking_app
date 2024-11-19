// views/edit_text_note_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/note_controller.dart';
import '../models/note.dart';

class EditTextNoteView extends StatelessWidget {
  final Note note;

  const EditTextNoteView({required this.note, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedTitle = titleController.text;
                final updatedContent = contentController.text;

                if (updatedTitle.isNotEmpty && updatedContent.isNotEmpty) {
                  Provider.of<NoteController>(context, listen: false)
                      .updateTextNote(note.id, updatedTitle, updatedContent);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in both fields')),
                  );
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
