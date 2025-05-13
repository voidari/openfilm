import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:openfilm/drawer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _isVideoMode = true;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high);

    await _controller.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<String> _getFilePath(String ext) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    return join(dir.path, fileName);
  }

  Future<void> _startRecording() async {
    if (!_controller.value.isRecordingVideo) {
      final path = await _getFilePath('mp4');
      await _controller.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    if (_controller.value.isRecordingVideo) {
      final recordedFile = await _controller.stopVideoRecording();
      setState(() => _isRecording = false);

      // Move to app document directory
      final targetPath = await _getFilePath('mp4');
      final targetFile = File(targetPath);

      await File(recordedFile.path).copy(targetFile.path);
      print('Video saved to ${targetFile.path}');

      await File(recordedFile.path).delete();
    }
  }

  Future<void> _takePhoto() async {
    final path = await _getFilePath('jpg');
    final file = await _controller.takePicture();
    print('Photo saved to ${file.path}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildControlRow() {
    if (_isVideoMode) {
      return IconButton(
        icon: Icon(
          _isRecording ? Icons.stop : Icons.fiber_manual_record,
          color: _isRecording ? Colors.red : Colors.white,
          size: 36,
        ),
        onPressed: _isRecording ? _stopRecording : _startRecording,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.camera, color: Colors.white, size: 36),
        onPressed: _takePhoto,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      drawer: AppDrawer(),
      body:
          _isInitialized
              ? Stack(
                children: [
                  CameraPreview(_controller),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        _buildControlRow(),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isVideoMode = !_isVideoMode;
                            });
                          },
                          child: Text(
                            _isVideoMode
                                ? 'Switch to Photo'
                                : 'Switch to Video',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Center(child: CircularProgressIndicator()),
    );
  }
}
