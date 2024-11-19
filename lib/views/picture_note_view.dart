// views/picture_note_view.dart
import 'dart:io';
import 'package:flutter/material.dart';

class PictureNoteView extends StatelessWidget {
  final String imagePath;
  final String title;

  const PictureNoteView({required this.imagePath, required this.title, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: imagePath.isNotEmpty
            ? Image.file(File(imagePath))
            : Text('No image available'),
      ),
    );
  }
}
