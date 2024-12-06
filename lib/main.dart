import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'screens/image_cropper_screen.dart';
import 'screens/display_results_screen.dart';
import 'services/ocr_service.dart';
import 'services/dicta_service.dart';
import 'services/sefaria_service.dart';

void main() {
  // Create services
  final dictaService = DictaService();
  final sefariaService = SefariaService(dictaService);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sefaria Text Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageCropperScreen(imageFile: imageFile),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sefaria Text Detector'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(context),
              child: Text('Take Picture'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final XFile? pickedFile = await _picker.pickImage(
                  source: ImageSource.gallery
                );
                if (pickedFile != null) {
                  File imageFile = File(pickedFile.path);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageCropperScreen(imageFile: imageFile),
                    ),
                  );
                }
              },
              child: Text('Choose from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
