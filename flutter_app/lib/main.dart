import 'package:flutter/material.dart';
import 'screens/camera_screen.dart';
import 'screens/image_cropper_screen.dart';
import 'screens/display_results_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter OCR App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => CameraScreen(),
        '/crop': (context) => ImageCropperScreen(),
        '/results': (context) => DisplayResultsScreen(),
      },
    );
  }
}
