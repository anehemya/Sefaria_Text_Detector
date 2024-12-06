import '../models/sefaria_match.dart';

class OCRResult {
  final String text;
  final List<SefariaMatch>? matches;

  OCRResult({
    required this.text,
    this.matches,
  });

  @override
  String toString() {
    return 'OCRResult(text: $text, matches: $matches)';
  }
} 