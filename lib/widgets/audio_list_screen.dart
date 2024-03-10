import 'dart:io';
import 'package:flutter/material.dart';
import 'package:youtube_downloder_final/screens/loading_full_screen.dart';
import 'package:youtube_downloder_final/widgets/audio_player_widget.dart';

import '../constants/constants.dart';

class AudioListScreen extends StatefulWidget {
  final String audioDirectoryPath;

  const AudioListScreen({Key? key, required this.audioDirectoryPath})
      : super(key: key);

  @override
  AudioListScreenState createState() => AudioListScreenState();
}

class AudioListScreenState extends State<AudioListScreen> {
  late Future<List<String>> audioPaths;

  @override
  void initState() {
    super.initState();
    audioPaths = getAudioPaths();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CustBackButton(),
        title: const Text(
          'Audio List',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: textColor1,
          ),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: audioPaths,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: FullScreenLoader(
                overlayColor: Colors.transparent,
                loaderColor: Colors.black,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No audios found.'));
          } else {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final audioPath = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    showAudioPlayer(context, audioPath);
                  },
                  child: ListTile(
                    leading: const Icon(Icons.music_note, color: iconsColor),
                    title: Text(
                      audioPath
                          .split('/')
                          .last
                          .replaceAll('_', ' ')
                          .replaceAll('.mp3', ''),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteAudio(context, audioPath);
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<String>> getAudioPaths() async {
    Directory directory = Directory(widget.audioDirectoryPath);
    List<String> audioPaths = [];

    try {
      List<FileSystemEntity> files = directory.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          audioPaths.add(file.path);
        }
      }
    } catch (e) {
      CustomSnackbar.showSnackbar(
        context: context,
        content: const Text(
          "An Error Ocurred",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: tatiaryBackGround, // Set your desired background color
        duration: const Duration(seconds: 3), // Set your desired duration
      );
    }

    return audioPaths;
  }

  void showAudioPlayer(BuildContext context, String audioPath) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AudioPlayerWidget(audioPath: audioPath);
      },
    );
  }

  void _deleteAudio(BuildContext context, String audioPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this audio?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel', style: TextStyle(color: textColor1)),
            ),
            TextButton(
              onPressed: () {
                _performDeleteAudio(context, audioPath);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete', style: TextStyle(color: textColor1)),
            ),
          ],
        );
      },
    );
  }

  void _performDeleteAudio(BuildContext context, String audioPath) {
    File audioFile = File(audioPath);
    audioFile.deleteSync();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleted successfully'),
      ),
    );

    // Reload the audio list
    setState(() {
      audioPaths = getAudioPaths();
    });
  }
}
