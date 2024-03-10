import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:youtube_downloder_final/screens/loading_full_screen.dart';
import 'package:youtube_downloder_final/widgets/video_player_screen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../constants/constants.dart';

class VideoListScreen extends StatefulWidget {
  final String videoDirectoryPath;

  const VideoListScreen({Key? key, required this.videoDirectoryPath})
      : super(key: key);

  @override
  VideoListScreenState createState() => VideoListScreenState();
}

class VideoListScreenState extends State<VideoListScreen> {
  late List<VideoItem> videoItems;

  @override
  void initState() {
    super.initState();
    videoItems = []; // Initialize videoItems
    _loadVideoItems();
  }

  void _loadVideoItems() async {
    try {
      List<VideoItem> items = await getVideoItems();
      setState(() {
        videoItems = items;
      });
    } catch (e) {
      Future.microtask(() {
        CustomSnackbar.showSnackbar(
          context: context,
          content: const Text(
            "An Error Ocurred",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor:
              tatiaryBackGround, // Set your desired background color
          duration: const Duration(seconds: 3), // Set your desired duration
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Downloaded Video List',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: textColor1,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildVideoList(),
    );
  }

  Widget _buildVideoList() {
    if (videoItems.isEmpty) {
      return const Center(
        child: FullScreenLoader(
          overlayColor: Colors.transparent,
          loaderColor: secondaryBackGround,
        ),
      );
    } else {
      return ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        itemCount: videoItems.length,
        itemBuilder: (context, index) {
          final videoItem = videoItems[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    videoPath: videoItem.videoPath,
                    videoTitle: videoItem.videoTitle,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.memory(
                          videoItem.thumbnailBytes,
                          width: 80,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          videoItem.videoTitle
                              .replaceAll('_', ' ')
                              .replaceAll('-', ' ')
                              .replaceAll('.mp4', ''),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteVideo(context, videoItem.videoPath);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<List<VideoItem>> getVideoItems() async {
    Directory directory = Directory(widget.videoDirectoryPath);
    List<VideoItem> videoItems = [];

    try {
      List<FileSystemEntity> files = directory.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.mp4')) {
          final thumbnailBytes = await VideoThumbnail.thumbnailData(
            video: file.path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 100,
            quality: 25,
          );

          videoItems.add(VideoItem(
            videoPath: file.path,
            videoTitle: file.uri.pathSegments.last,
            thumbnailBytes: thumbnailBytes!,
          ));
        }
      }
    } catch (e) {
      Future.microtask(() {
        CustomSnackbar.showSnackbar(
          context: context,
          content: const Text(
            "An Error Ocurred",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor:
              tatiaryBackGround, // Set your desired background color
          duration: const Duration(seconds: 3), // Set your desired duration
        );
      });
    }

    return videoItems;
  }

  void _deleteVideo(BuildContext context, String videoPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this video?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel', style: TextStyle(color: textColor1)),
            ),
            TextButton(
              onPressed: () {
                _performDeleteVideo(context, videoPath);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete', style: TextStyle(color: textColor1)),
            ),
          ],
        );
      },
    );
  }

  void _performDeleteVideo(BuildContext context, String videoPath) {
    File videoFile = File(videoPath);
    videoFile.deleteSync();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleted successfully'),
      ),
    );

    // Reload the video list
    _loadVideoItems();
  }
}

class VideoItem {
  final String videoPath;
  final String videoTitle;
  final Uint8List thumbnailBytes;

  VideoItem({
    required this.videoPath,
    required this.videoTitle,
    required this.thumbnailBytes,
  });
}
