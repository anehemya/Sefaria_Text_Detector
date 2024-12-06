import 'dart:io';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:sefaria_text_detector/services/sefaria_service.dart';
import '../models/ocr_result.dart';
import '../models/sefaria_match.dart';

class OCRService {
  final SefariaService _sefariaService;
  
  OCRService(this._sefariaService);

  Future<OCRResult> processImage(File imageFile) async {
    try {
      print('\nOCR Service - Starting image processing');
      print('OCR Service - Processing file: ${imageFile.path}');
      
      print('OCR Service - Starting text recognition...');
      final recognizedText = await FlutterTesseractOcr.extractText(
        imageFile.path,
        language: 'eng+heb',
      );
      print('OCR Service - Recognized text: "$recognizedText"');

      if (recognizedText.isEmpty) {
        print('OCR Service - No text recognized in image');
        throw Exception('No text recognized in image');
      }

      print('OCR Service - Starting Sefaria search with recognized text');
      final searchResult = await _sefariaService.searchText(recognizedText);
      print('OCR Service - Search completed');
      
      return OCRResult(
        text: recognizedText,
        matches: _sefariaService.parseResults(searchResult),
      );
    } catch (e) {
      print('OCR Service - Error occurred: $e');
      throw Exception('Failed to process image: $e');
    }
  }
}