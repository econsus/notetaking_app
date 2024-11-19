import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record_platform_interface/record_platform_interface.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '/controllers/note_controller.dart';
import '/views/edit_text_note_view.dart';
import '/views/picture_note_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecordPlatform _recorder = RecordPlatform.instance;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  @override
  void dispose() {
    super.dispose();
    _disposeRecorder();
  }

  // Initialize the recorder and check if it's ready
  Future<void> _initializeRecorder() async {
    const recorderId = 'default';  // Use the correct recorder ID

    try {
      // Check for permission before initializing
      bool hasPermission = await _recorder.hasPermission(recorderId);
      if (hasPermission) {
        // Initialize the recorder (create it if not already initialized)
        await _recorder.create(recorderId);
        // Check the current status after initialization (we assume it's ready after creation)
        print('Recorder initialized');
      } else {
        print('Recording permission not granted');
      }
    } catch (e) {
      print("Error initializing recorder: $e");
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
            subtitle: note.type == 'text'
                ? Text(note.content ?? 'No content')
                : note.type == 'audio'
                    ? Text('Audio Note')
                    : note.type == 'image'
                        ? Text('Image Note')
                        : Container(),
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
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                noteController.deleteNote(note.id);
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Button for adding text note
          FloatingActionButton(
            onPressed: () => _showTextNoteDialog(context),
            heroTag: 'textNote',
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          // Button for taking a picture note
          FloatingActionButton(
            onPressed: () => _capturePictureNote(context),
            heroTag: 'pictureNote',
            child: Icon(Icons.camera_alt),
          ),
          SizedBox(height: 10),
          // Button for recording audio note
          GestureDetector(
            onLongPressStart: (_) => _startRecording(),
            onLongPressEnd: (_) => _stopRecording(context),
            child: FloatingActionButton(
              onPressed: () {
                // This onPressed is required but does not need to do anything here
              },
              heroTag: 'audioNote',
              child: Icon(Icons.mic),
            ),
          ),
        ],
      ),
    );
  }

  // Start recording
  Future<void> _startRecording() async {
    const recorderId = 'default';

    try {
      // Ensure recorder is initialized and permission granted
      bool hasPermission = await _recorder.hasPermission(recorderId);
      if (hasPermission) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // Define recording configuration
        final config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        // Start recording
        await _recorder.start(recorderId, config, path: path);

        setState(() {
          _recordedFilePath = path;
        });
      } else {
        print('Recording permission not granted');
      }
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  // Stop recording
  Future<void> _stopRecording(BuildContext context) async {
    const recorderId = 'default';  // Recorder ID

    try {
      final filePath = await _recorder.stop(recorderId);
      if (filePath != null) {
        setState(() {
          _recordedFilePath = filePath;
        });

        final titleController = TextEditingController();
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
                          .addAudioNote(title, filePath);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Add'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error stopping recording: $e");
    }
  }

  // Dispose of the recorder when done
  Future<void> _disposeRecorder() async {
    const recorderId = 'default';  // Use the correct recorder ID
    try {
      await _recorder.dispose(recorderId); // Properly dispose of recorder
      print("Recorder disposed");
    } catch (e) {
      print("Error disposing recorder: $e");
    }
  }

  Future<void> _playAudio(String filePath) async {
    final player = AudioPlayer();
    await player.play(DeviceFileSource(filePath));
  }

  void _showTextNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

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
                      .addTextNote(title, content);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                        .addPictureNote(title, image.path);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Add'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  }
}
