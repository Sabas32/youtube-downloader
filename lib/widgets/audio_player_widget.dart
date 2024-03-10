import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../constants/constants.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;

  const AudioPlayerWidget({super.key, required this.audioPath});

  @override
  AudioPlayerWidgetState createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = true;

  Duration _duration = const Duration();
  Duration _position = const Duration();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadAudio();
  }

  Future<void> _loadAudio() async {
    await _audioPlayer.setFilePath(widget.audioPath);
    _audioPlayer.durationStream.listen((event) {
      setState(() {
        _duration = event ?? const Duration();
      });
    });
    _audioPlayer.positionStream.listen((event) {
      setState(() {
        _position = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isPlaying) {
      _audioPlayer.play();
    } else {
      _audioPlayer.pause();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView(
        // mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Audio Player',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: iconsColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundColor: iconsColor,
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _togglePlayback();
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Now Playing',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _getAudioFileName().replaceAll('_', ' ').replaceAll('.mp3', ''),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildDurationProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildDurationProgressIndicator() {
    return Column(
      children: [
        Slider(
          value: _position.inMilliseconds.toDouble(),
          onChanged: (value) {
            final newPosition = Duration(milliseconds: value.toInt());
            _audioPlayer.seek(newPosition);
          },
          min: 0.0,
          max: _duration.inMilliseconds.toDouble(),
          activeColor: iconsColor,
          inactiveColor: Colors.grey,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getAudioFileName() {
    return widget.audioPath.split('/').last; // Extracting the file name
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  String _formatDuration(Duration duration) {
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
