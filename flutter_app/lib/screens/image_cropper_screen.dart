import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class ImageCropperScreen extends StatefulWidget {
  @override
  _ImageCropperScreenState createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  File? _croppedImage;

  @override
  Widget build(BuildContext context) {
    final File image = ModalRoute.of(context)!.settings.arguments as File;

    Future<void> _cropImage() async {
      final cropped = await ImageCropper().cropImage(
        sourcePath: image.path,
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

      // Navigate to the Results screen after cropping
      Navigator.pushNamed(context, '/results', arguments: _croppedImage);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Image'),
      ),
      body: Center(
        child: _croppedImage == null
            ? Image.file(image)
            : Image.file(_croppedImage!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cropImage,
        tooltip: 'Crop Image',
        child: Icon(Icons.crop),
      ),
    );
  }
}
