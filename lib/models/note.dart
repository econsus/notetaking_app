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

  // Convert a Note instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'filePath': filePath,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Create a Note instance from a Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      type: map['type'],
      filePath: map['filePath'],
      latitude: map['latitude'] != null ? map['latitude'] as double : null,
      longitude: map['longitude'] != null ? map['longitude'] as double : null,
    );
  }
}
