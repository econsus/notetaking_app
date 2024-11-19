// models/note.dart
class Note {
  final String id;
  final String title;
  final String? content;
  final String type; // 'text', 'image', or 'audio'
  final String? filePath; // For image or audio notes

  Note({
    required this.id,
    required this.title,
    this.content,
    required this.type,
    this.filePath,
  });
}