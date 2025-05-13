import 'dart:io';
import 'package:flutter/material.dart';
import 'package:openfilm/drawer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  List<File> _mediaFiles = [];

  @override
  void initState() {
    super.initState();
    _loadMediaFiles();
  }

  Future<void> _loadMediaFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(dir.path);
    final files = mediaDir.listSync();

    setState(() {
      _mediaFiles =
          files.whereType<File>().where((file) {
            final ext = file.path.split('.').last.toLowerCase();
            final isSupported = [
              'jpg',
              'jpeg',
              'png',
              'gif',
              'mp4',
            ].contains(ext);
            return isSupported && file.lengthSync() > 0;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Media')),
      drawer: AppDrawer(),
      body:
          _mediaFiles.isEmpty
              ? Center(child: Text('No media available'))
              : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _mediaFiles.length,
                itemBuilder: (context, index) {
                  final file = _mediaFiles[index];
                  final ext = file.path.split('.').last;

                  if (ext == 'mp4') {
                    // Display video
                    return VideoThumbnail(file: file);
                  } else {
                    // Display image
                    return Image.file(
                      file,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey[700],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
    );
  }
}

class VideoThumbnail extends StatelessWidget {
  final File file;
  const VideoThumbnail({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoPlayerController>(
      future: _initializeController(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: () {
              // Open the video in a full-screen player
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => VideoPlayerPage(controller: snapshot.data!),
                ),
              );
            },
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayer(snapshot.data!),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<VideoPlayerController> _initializeController() async {
    return VideoPlayerController.file(file)..initialize();
  }
}

class VideoPlayerPage extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayerPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video')),
      drawer: AppDrawer(),
      body: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.value.isPlaying ? controller.pause() : controller.play();
        },
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
