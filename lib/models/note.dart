// models/note.dart
class Note {
  final String id;
  final String title;
  final String? content;
  final String type; // 'text', 'image', or 'audio'
  final String? filePath; // For image or audio notes
  final double? latitude; // Latitude coordinate
  final double? longitude; // Longitude coordinate

  Note({
    required this.id,
    required this.title,
    this.content,
    required this.type,
    this.filePath,
    this.latitude,
    this.longitude,
  });
}
