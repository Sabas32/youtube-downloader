import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:youtube_downloder_final/widgets/video_list_widget.dart';

import '../widgets/audio_list_screen.dart';

class Downloads extends StatefulWidget {
  const Downloads({super.key});

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const VideoListScreen(
      videoDirectoryPath:
          '/storage/emulated/0/Download/youtube_downloader/Video',
    ),
    AudioListScreen(
      audioDirectoryPath: Directory(
        '/storage/emulated/0/Download/youtube_downloader/Audio/',
      ).path,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              mainAxisAlignment: MainAxisAlignment.center,
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[200]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: Icons.videocam,
                  text: 'Videos',
                ),
                GButton(
                  icon: Icons.audiotrack_rounded,
                  text: 'Audios',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
