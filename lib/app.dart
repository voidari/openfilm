import 'package:flutter/material.dart';
import 'package:openfilm/camera.dart';
import 'package:openfilm/home.dart';
import 'package:openfilm/media.dart';

class FilmApp extends StatelessWidget {
  const FilmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenFilm',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: HomePage(),
      routes: {
        '/home': (context) => HomePage(),
        '/camera': (context) => CameraPage(),
        '/media': (context) => MediaPage(),
      },
    );
  }
}
