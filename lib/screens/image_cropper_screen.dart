import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
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
        title: const Text('Crop Image'),
        elevation: 0, // Modern look with no shadow
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Stack(
        children: [
          // Image display with rounded corners and padding
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: _croppedImage == null
                    ? Image.file(widget.imageFile)
                    : Image.file(_croppedImage!),
              ),
            ),
          ),
          // Processing overlay with blur effect
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Processing text...',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _cropImage,
        tooltip: 'Crop Image',
        icon: const Icon(Icons.crop),
        label: const Text('Crop'),
        elevation: 4,
      ),
    );
  }
}
