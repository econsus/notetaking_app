import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '/controllers/location_controller.dart';
import '/controllers/note_controller.dart';
import '/views/edit_text_note_view.dart';
import '/views/picture_note_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  String? _recordedFilePath;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializePlayer();
    _fetchLocation();
    _loadNotes();
  }

  @override
  void dispose() {
    super.dispose();
    _disposeRecorder();
    _disposePlayer();
  }

  Future<void> _fetchLocation() async {
    final locationController = Provider.of<LocationController>(context, listen: false);
    await locationController.fetchLocation();
  }

  Future<void> _initializeRecorder() async {
    try {
      await _recorder.openRecorder();
    } catch (e) {
      print("Error initializing recorder: $e");
    }
  }

  Future<void> _initializePlayer() async {
    try {
      await _player.openPlayer();
    } catch (e) {
      print("Error initializing player: $e");
    }
  }

  Future<void> _loadNotes() async {
    final noteController = Provider.of<NoteController>(context, listen: false);
    await noteController.fetchNotes(); // Fetch the notes, online or offline
  }

  // Method for opening Google Maps with coordinates
  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  // Record audio, stop recording, and save
  Future<void> _startRecording() async {
    try {
      if (!_isRecording) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
        await _recorder.startRecorder(toFile: path);

        setState(() {
          _isRecording = true;
          _recordedFilePath = path;
        });
      }
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  Future<void> _stopRecording(BuildContext context) async {
    try {
      if (_isRecording) {
        final filePath = await _recorder.stopRecorder();
        if (filePath != null) {
          setState(() {
            _isRecording = false;
            _recordedFilePath = filePath;
          });

          final titleController = TextEditingController();
          final locationController = Provider.of<LocationController>(context, listen: false);
          final location = locationController.currentPosition;

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Audio Note'),
                content: TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      final title = titleController.text;
                      if (title.isNotEmpty) {
                        Provider.of<NoteController>(context, listen: false)
                            .addAudioNote(
                          title,
                          filePath,
                          latitude: location?.latitude,
                          longitude: location?.longitude,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Add'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print("Error stopping recording: $e");
    }
  }

  Future<void> _disposeRecorder() async {
    try {
      await _recorder.closeRecorder();
    } catch (e) {
      print("Error disposing recorder: $e");
    }
  }

  Future<void> _disposePlayer() async {
    try {
      await _player.closePlayer();
    } catch (e) {
      print("Error disposing player: $e");
    }
  }

  // Play the audio file
  Future<void> _playAudio(String filePath) async {
    try {
      await _player.startPlayer(fromURI: filePath, codec: Codec.aacADTS);
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteController = Provider.of<NoteController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Add logout logic here
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: noteController.notes.length,
        itemBuilder: (context, index) {
          final note = noteController.notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.type == 'text')
                  Text(note.content ?? 'No content')
                else if (note.type == 'audio')
                  Text('Audio Note')
                else if (note.type == 'image')
                  Text('Image Note'),
                if (note.latitude != null && note.longitude != null)
                  Text('Lat: ${note.latitude}, Long: ${note.longitude}')
                else
                  Text('Lat: null, Long: null'),
              ],
            ),
            onTap: () {
              if (note.type == 'text') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditTextNoteView(note: note),
                  ),
                );
              } else if (note.type == 'audio') {
                _playAudio(note.filePath!);
              } else if (note.type == 'image') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PictureNoteView(
                      imagePath: note.filePath!,
                      title: note.title,
                    ),
                  ),
                );
              }
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (note.latitude != null && note.longitude != null)
                  IconButton(
                    icon: Icon(Icons.map),
                    onPressed: () {
                      if (note.latitude != null && note.longitude != null) {
                        _openGoogleMaps(note.latitude!, note.longitude!);
                      }
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    noteController.deleteNote(note.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => _showTextNoteDialog(context),
            heroTag: 'textNote',
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _capturePictureNote(context),
            heroTag: 'pictureNote',
            child: Icon(Icons.camera_alt),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onLongPressStart: (_) => _startRecording(),
            onLongPressEnd: (_) => _stopRecording(context),
            child: FloatingActionButton(
              onPressed: () {},
              heroTag: 'audioNote',
              child: Icon(Icons.mic),
            ),
          ),
        ],
      ),
    );
  }

  void _showTextNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final locationController = Provider.of<LocationController>(context, listen: false);
    final location = locationController.currentPosition;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Text Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Content'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final content = contentController.text;

                if (title.isNotEmpty && content.isNotEmpty) {
                  Provider.of<NoteController>(context, listen: false)
                      .addTextNote(
                    title,
                    content,
                    latitude: location?.latitude,
                    longitude: location?.longitude,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _capturePictureNote(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final titleController = TextEditingController();
      final locationController = Provider.of<LocationController>(context, listen: false);
      final location = locationController.currentPosition;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Picture Note'),
            content: TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final title = titleController.text;
                  if (title.isNotEmpty) {
                    Provider.of<NoteController>(context, listen: false)
                        .addPictureNote(
                      title,
                      image.path,
                      latitude: location?.latitude,
                      longitude: location?.longitude,
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Add'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  }
}
