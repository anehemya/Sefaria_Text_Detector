import 'package:flutter/material.dart';
import 'dart:io';
import '../services/ocr_service.dart';
import 'display_results_screen.dart';
import '../services/dicta_service.dart';
import '../services/sefaria_service.dart';
import 'package:image_cropper/image_cropper.dart';


class ImageCropperScreen extends StatefulWidget {
  final File imageFile;  // Parameter is named 'imageFile'

  const ImageCropperScreen({
    Key? key, 
    required this.imageFile,  // Make sure this matches
  }) : super(key: key);

  @override
  _ImageCropperScreenState createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  File? _croppedImage;
  bool _isProcessing = false;
  final _dictaService = DictaService();
  late final _sefariaService = SefariaService(_dictaService);
  late final _ocrService = OCRService(_sefariaService);

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final extractedText = await _ocrService.processImage(imageFile);
      
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayResultsScreen(
            result: extractedText,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing text: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _cropImage() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: widget.imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    if (cropped == null) return;

    setState(() {
      _croppedImage = File(cropped.path);
    });

    await _processImage(_croppedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Image'),
      ),
      body: Stack(
        children: [
          Center(
            child: _croppedImage == null
                ? Image.file(widget.imageFile)
                : Image.file(_croppedImage!),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Processing text...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProcessing ? null : _cropImage,
        tooltip: 'Crop Image',
        child: Icon(Icons.crop),
      ),
    );
  }
}
